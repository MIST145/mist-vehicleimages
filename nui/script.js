/* ===================================================== */
/*                  VEHICLE IMAGES MANAGER                */
/*                     JAVASCRIPT                         */
/* ===================================================== */

// Global Variables
let vehiclesData = [];
let currentVehicles = [];
let currentPage = 1;
let itemsPerPage = 50;
let isAdmin = false;
let config = {};
let currentEditModel = null;
let currentCategory = '';
let searchQuery = '';
let searchTimeout = null;

// DOM Elements
const app = document.getElementById('app');
const vehicleGrid = document.getElementById('vehicleGrid');
const loading = document.getElementById('loading');
const noResults = document.getElementById('noResults');
const searchInput = document.getElementById('searchInput');
const categorySelect = document.getElementById('categorySelect');
const adminActions = document.getElementById('adminActions');

// Stats
const totalVehiclesEl = document.getElementById('totalVehicles');
const customVehiclesEl = document.getElementById('customVehicles');
const currentCategoryEl = document.getElementById('currentCategory');

// Buttons
const closeBtn = document.getElementById('closeBtn');
const refreshBtn = document.getElementById('refreshBtn');
const addBtn = document.getElementById('addBtn');
const importBtn = document.getElementById('importBtn');
const exportBtn = document.getElementById('exportBtn');
const prevPage = document.getElementById('prevPage');
const nextPage = document.getElementById('nextPage');

// Modal Elements
const vehicleModal = document.getElementById('vehicleModal');
const importModal = document.getElementById('importModal');
const previewModal = document.getElementById('previewModal');
const contextMenu = document.getElementById('contextMenu');

// Intersection Observer for Lazy Loading (PHASE 2.3)
const imageObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const img = entry.target;
            if (img.dataset.src) {
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                imageObserver.unobserve(img);
            }
        }
    });
}, {
    rootMargin: '50px'
});

/* ===================================================== */
/*                  INITIALIZATION                        */
/* ===================================================== */

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'show':
            showApp();
            break;
        case 'hide':
            hideApp();
            break;
        case 'loadData':
            loadData(data.data);
            break;
        case 'receiveImage':
            updateVehicleImage(data.model, data.url);
            break;
        case 'vehicleAdded':
            addVehicleToList(data.vehicle);
            break;
        case 'vehicleUpdated':
            updateVehicleInList(data.model, data.vehicle);
            break;
        case 'vehicleDeleted':
            removeVehicleFromList(data.model);
            break;
        case 'searchResults':
            displaySearchResults(data.results);
            break;
        case 'categoryResults':
            displayCategoryResults(data.results);
            break;
        case 'exportData':
            downloadExport(data.data);
            break;
        case 'notification':
            showNotification(data.type, data.message, data.duration);
            break;
        case 'showPreview':
            showPreviewModal(data.vehicle);
            break;
        case 'openImport':
            openImportModal();
            break;
    }
});

/* ===================================================== */
/*                  APP CONTROL                           */
/* ===================================================== */

function showApp() {
    app.classList.remove('hidden');
    playSound('SELECT');
    requestVehicleData();
}

function hideApp() {
    app.classList.add('hidden');
    closeAllModals();
}

function requestVehicleData() {
    showLoading();
    post('getVehicles');
}

/* ===================================================== */
/*                  DATA MANAGEMENT                       */
/* ===================================================== */

function loadData(data) {
    vehiclesData = data.vehicles || [];
    currentVehicles = [...vehiclesData];
    isAdmin = data.isAdmin || false;
    config = data.config || {};
    
    updateStats(data.stats);
    populateCategories();
    renderVehicles();
    hideLoading();
    
    if (isAdmin) {
        adminActions.classList.remove('hidden');
    } else {
        adminActions.classList.add('hidden');
    }
}

function updateStats(stats) {
    if (!stats) return;
    
    totalVehiclesEl.textContent = stats.total || 0;
    customVehiclesEl.textContent = stats.custom || 0;
}

function populateCategories() {
    categorySelect.innerHTML = '<option value="">All Categories</option>';
    
    if (config.categories) {
        config.categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = `${cat.icon} ${cat.label}`;
            categorySelect.appendChild(option);
        });
    }
}

/* ===================================================== */
/*                  RENDERING                             */
/* ===================================================== */

function renderVehicles() {
    vehicleGrid.innerHTML = '';
    
    if (currentVehicles.length === 0) {
        showNoResults();
        return;
    }
    
    hideNoResults();
    
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageVehicles = currentVehicles.slice(startIndex, endIndex);
    
    pageVehicles.forEach(vehicle => {
        const card = createVehicleCard(vehicle);
        vehicleGrid.appendChild(card);
    });
    
    updatePagination();
}

function createVehicleCard(vehicle) {
    const modelName = vehicle.name.replace('.png', '');
    const category = getCategoryInfo(vehicle.category);
    
    const card = document.createElement('div');
    card.className = 'vehicle-card';
    card.dataset.model = modelName;
    
    card.innerHTML = `
        <img class="vehicle-image" data-src="${vehicle.url}" alt="${modelName}" onerror="this.src='${config.placeholder || ''}'" loading="lazy">
        <div class="vehicle-info">
            <div class="vehicle-name">
                ${modelName}
                ${vehicle.custom ? '<span class="vehicle-badge custom">⭐ CUSTOM</span>' : ''}
            </div>
            <div class="vehicle-category">
                <span>${category.icon}</span>
                <span>${category.label}</span>
            </div>
            ${isAdmin ? `
                <div class="vehicle-actions">
                    <button class="btn btn-secondary btn-small" onclick="editVehicle('${modelName}')">
                        <span>✏️</span> Edit
                    </button>
                    <button class="btn btn-danger btn-small" onclick="deleteVehicle('${modelName}')">
                        <span>🗑️</span> Delete
                    </button>
                </div>
            ` : ''}
        </div>
    `;
    
    // Apply Lazy Loading to the image
    const img = card.querySelector('.vehicle-image');
    imageObserver.observe(img);
    
    card.addEventListener('click', (e) => {
        if (!e.target.closest('.vehicle-actions')) {
            showVehiclePreview(vehicle);
        }
    });
    
    if (isAdmin) {
        card.addEventListener('contextmenu', (e) => {
            e.preventDefault();
            showContextMenu(e.pageX, e.pageY, modelName);
        });
    }
    
    return card;
}

function getCategoryInfo(categoryId) {
    if (!config.categories) {
        return {icon: '❓', label: 'Other'};
    }
    
    const category = config.categories.find(c => c.id === categoryId);
    return category || {icon: '❓', label: 'Other'};
}

/* ===================================================== */
/*                  PAGINATION                            */
/* ===================================================== */

function updatePagination() {
    const totalPages = Math.ceil(currentVehicles.length / itemsPerPage);
    
    document.getElementById('currentPage').textContent = currentPage;
    document.getElementById('totalPages').textContent = totalPages;
    
    prevPage.disabled = currentPage === 1;
    nextPage.disabled = currentPage >= totalPages;
}

/* ===================================================== */
/*                  SEARCH & FILTER                       */
/* ===================================================== */

function filterVehicles() {
    currentVehicles = vehiclesData.filter(vehicle => {
        const modelName = vehicle.name.replace('.png', '').toLowerCase();
        const matchesSearch = searchQuery === '' || modelName.includes(searchQuery.toLowerCase());
        const matchesCategory = currentCategory === '' || vehicle.category === currentCategory;
        
        return matchesSearch && matchesCategory;
    });
    
    currentPage = 1;
    renderVehicles();
    
    currentCategoryEl.textContent = currentCategory === '' ? 'All' : getCategoryInfo(currentCategory).label;
}

// Debounce for search (PHASE 2.4)
searchInput.addEventListener('input', (e) => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        searchQuery = e.target.value;
        filterVehicles();
    }, 300);
});

categorySelect.addEventListener('change', (e) => {
    currentCategory = e.target.value;
    filterVehicles();
});

/* ===================================================== */
/*                  VEHICLE ACTIONS                       */
/* ===================================================== */

function addVehicle() {
    if (!isAdmin) return;
    
    currentEditModel = null;
    openVehicleModal('Add Vehicle');
}

function editVehicle(model) {
    if (!isAdmin) return;
    
    const vehicle = vehiclesData.find(v => v.name.replace('.png', '') === model);
    if (!vehicle) return;
    
    currentEditModel = model;
    openVehicleModal('Edit Vehicle', vehicle);
}

async function deleteVehicle(model) {
    if (!isAdmin) return;
    
    if (confirm(`Are you sure you want to delete the vehicle "${model}"?`)) {
        await post('deleteVehicle', {model: model});
        playSound('DELETE');
    }
}

async function saveVehicle() {
    const modelInput = document.getElementById('modelInput');
    const urlInput = document.getElementById('urlInput');
    const categoryInput = document.getElementById('categoryInput');
    const customInput = document.getElementById('customInput');
    
    const model = modelInput.value.trim().replace('.png', '');
    const url = urlInput.value.trim();
    const category = categoryInput.value;
    const custom = customInput.checked;
    
    if (!model || !url) {
        showNotification('error', 'Please fill in all required fields!');
        return;
    }
    
    if (!isValidUrl(url)) {
        showNotification('error', 'Invalid URL!');
        return;
    }
    
    const data = {
        model: model + '.png',
        url: url,
        category: category,
        custom: custom
    };
    
    if (currentEditModel) {
        await post('updateVehicle', data);
    } else {
        await post('addVehicle', data);
    }
    
    closeVehicleModal();
    playSound('SELECT');
}

/* ===================================================== */
/*                  IMPORT/EXPORT                         */
/* ===================================================== */

function openImportModal() {
    if (!isAdmin) return;
    
    importModal.classList.remove('hidden');
    document.getElementById('importInput').value = '';
    document.getElementById('overwriteInput').checked = false;
}

function closeImportModal() {
    importModal.classList.add('hidden');
}

async function importData() {
    const importInput = document.getElementById('importInput');
    const overwriteInput = document.getElementById('overwriteInput');
    
    let data;
    try {
        data = JSON.parse(importInput.value);
    } catch (e) {
        showNotification('error', 'Invalid JSON!');
        return;
    }
    
    if (!data.pictures || !Array.isArray(data.pictures)) {
        showNotification('error', 'Invalid JSON format!');
        return;
    }
    
    const overwrite = overwriteInput.checked;
    
    if (overwrite) {
        if (!confirm('This will overwrite ALL existing data! Continue?')) {
            return;
        }
    }
    
    await post('importData', {data: data, overwrite: overwrite});
    closeImportModal();
    playSound('SELECT');
}

async function exportData() {
    if (!isAdmin) return;
    
    await post('exportData');
}

function downloadExport(data) {
    const json = JSON.stringify(data, null, 2);
    const blob = new Blob([json], {type: 'application/json'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `vehicles_export_${new Date().getTime()}.json`;
    a.click();
    URL.revokeObjectURL(url);
    
    showNotification('success', 'Data exported successfully!');
}

/* ===================================================== */
/*                  MODALS                                */
/* ===================================================== */

function openVehicleModal(title, vehicle = null) {
    document.getElementById('modalTitle').textContent = title;
    
    const modelInput = document.getElementById('modelInput');
    const urlInput = document.getElementById('urlInput');
    const categoryInput = document.getElementById('categoryInput');
    const customInput = document.getElementById('customInput');
    
    categoryInput.innerHTML = '';
    if (config.categories) {
        config.categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = `${cat.icon} ${cat.label}`;
            categoryInput.appendChild(option);
        });
    }
    
    if (vehicle) {
        modelInput.value = vehicle.name.replace('.png', '');
        modelInput.disabled = true;
        urlInput.value = vehicle.url;
        categoryInput.value = vehicle.category || 'other';
        customInput.checked = vehicle.custom || false;
        updatePreview(vehicle.url);
    } else {
        modelInput.value = '';
        modelInput.disabled = false;
        urlInput.value = '';
        categoryInput.value = 'other';
        customInput.checked = false;
        clearPreview();
    }
    
    vehicleModal.classList.remove('hidden');
}

function closeVehicleModal() {
    vehicleModal.classList.add('hidden');
    currentEditModel = null;
}

function showVehiclePreview(vehicle) {
    showPreviewModal(vehicle);
}

function showPreviewModal(vehicle) {
    const modelName = vehicle.name.replace('.png', '');
    const category = getCategoryInfo(vehicle.category);
    
    document.getElementById('previewTitle').textContent = `Preview: ${modelName}`;
    document.getElementById('previewFullImage').src = vehicle.url;
    document.getElementById('previewModel').textContent = modelName;
    document.getElementById('previewCategory').textContent = `${category.icon} ${category.label}`;
    document.getElementById('previewUrl').href = vehicle.url;
    document.getElementById('previewUrl').textContent = vehicle.url;
    
    previewModal.classList.remove('hidden');
}

function closePreviewModal() {
    previewModal.classList.add('hidden');
}

function closeAllModals() {
    vehicleModal.classList.add('hidden');
    importModal.classList.add('hidden');
    previewModal.classList.add('hidden');
    contextMenu.classList.add('hidden');
}

/* ===================================================== */
/*                  CONTEXT MENU                          */
/* ===================================================== */

function showContextMenu(x, y, model) {
    contextMenu.style.left = x + 'px';
    contextMenu.style.top = y + 'px';
    contextMenu.classList.remove('hidden');
    
    document.getElementById('contextEdit').onclick = () => {
        editVehicle(model);
        contextMenu.classList.add('hidden');
    };
    
    document.getElementById('contextPreview').onclick = () => {
        const vehicle = vehiclesData.find(v => v.name.replace('.png', '') === model);
        if (vehicle) showVehiclePreview(vehicle);
        contextMenu.classList.add('hidden');
    };
    
    document.getElementById('contextDelete').onclick = () => {
        deleteVehicle(model);
        contextMenu.classList.add('hidden');
    };
}

document.addEventListener('click', () => {
    contextMenu.classList.add('hidden');
});

/* ===================================================== */
/*                  PREVIEW SYSTEM                        */
/* ===================================================== */

function updatePreview(url) {
    const previewImage = document.getElementById('previewImage');
    const previewPlaceholder = document.getElementById('previewPlaceholder');
    
    if (url && isValidUrl(url)) {
        previewImage.src = url;
        previewImage.classList.remove('hidden');
        previewPlaceholder.classList.add('hidden');
    } else {
        clearPreview();
    }
}

function clearPreview() {
    const previewImage = document.getElementById('previewImage');
    const previewPlaceholder = document.getElementById('previewPlaceholder');
    
    previewImage.src = '';
    previewImage.classList.add('hidden');
    previewPlaceholder.classList.remove('hidden');
}

document.getElementById('urlInput').addEventListener('input', (e) => {
    updatePreview(e.target.value);
});

/* ===================================================== */
/*                  NOTIFICATIONS                         */
/* ===================================================== */

function showNotification(type, message, duration = 3000) {
    const container = document.getElementById('notificationContainer');
    
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    
    const icons = {
        success: '✓',
        error: '✗',
        warning: '⚠',
        info: 'ℹ'
    };
    
    notification.innerHTML = `
        <div class="notification-icon">${icons[type] || 'ℹ'}</div>
        <div class="notification-message">${message}</div>
    `;
    
    container.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            container.removeChild(notification);
        }, 300);
    }, duration);
}

/* ===================================================== */
/*                  UTILITIES                             */
/* ===================================================== */

function isValidUrl(url) {
    try {
        new URL(url);
        return url.startsWith('http://') || url.startsWith('https://');
    } catch {
        return false;
    }
}

function showLoading() {
    loading.classList.remove('hidden');
    vehicleGrid.classList.add('hidden');
    noResults.classList.add('hidden');
}

function hideLoading() {
    loading.classList.add('hidden');
    vehicleGrid.classList.remove('hidden');
}

function showNoResults() {
    noResults.classList.remove('hidden');
    vehicleGrid.classList.add('hidden');
}

function hideNoResults() {
    noResults.classList.add('hidden');
    vehicleGrid.classList.remove('hidden');
}

function addVehicleToList(vehicle) {
    vehiclesData.push(vehicle);
    filterVehicles();
    showNotification('success', 'Vehicle added!');
}

function updateVehicleInList(model, vehicle) {
    const index = vehiclesData.findIndex(v => v.name.replace('.png', '') === model);
    if (index !== -1) {
        vehiclesData[index] = vehicle;
        filterVehicles();
        showNotification('success', 'Vehicle updated!');
    }
}

function removeVehicleFromList(model) {
    const index = vehiclesData.findIndex(v => v.name.replace('.png', '') === model);
    if (index !== -1) {
        vehiclesData.splice(index, 1);
        filterVehicles();
        showNotification('success', 'Vehicle deleted!');
    }
}

function updateVehicleImage(model, url) {
    const card = document.querySelector(`[data-model="${model}"]`);
    if (card) {
        const img = card.querySelector('.vehicle-image');
        if (img) img.src = url;
    }
}

function displaySearchResults(results) {
    currentVehicles = results;
    currentPage = 1;
    renderVehicles();
}

function displayCategoryResults(results) {
    currentVehicles = results;
    currentPage = 1;
    renderVehicles();
}

async function playSound(sound, soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET') {
    await post('playSound', {sound: sound, soundSet: soundSet});
}

async function post(action, data = {}) {
    try {
        const response = await fetch(`https://mist-vehicleimages/${action}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('NUI Post Error:', error);
        return null;
    }
}

function GetParentResourceName() {
    const url = window.location.href;
    const match = url.match(/https?:\/\/([^\/]+)\//);
    return match ? match[1] : 'mist-vehicleimages';
}

/* ===================================================== */
/*                  EVENT LISTENERS                       */
/* ===================================================== */

closeBtn.addEventListener('click', async () => {
    await post('close');
    playSound('BACK');
});

refreshBtn.addEventListener('click', () => {
    requestVehicleData();
    playSound('SELECT');
});

addBtn.addEventListener('click', addVehicle);
importBtn.addEventListener('click', openImportModal);
exportBtn.addEventListener('click', exportData);

prevPage.addEventListener('click', () => {
    if (currentPage > 1) {
        currentPage--;
        renderVehicles();
        playSound('NAV_UP_DOWN');
    }
});

nextPage.addEventListener('click', () => {
    const totalPages = Math.ceil(currentVehicles.length / itemsPerPage);
    if (currentPage < totalPages) {
        currentPage++;
        renderVehicles();
        playSound('NAV_UP_DOWN');
    }
});

document.getElementById('modalCloseBtn').addEventListener('click', closeVehicleModal);
document.getElementById('modalCancelBtn').addEventListener('click', closeVehicleModal);
document.getElementById('modalSaveBtn').addEventListener('click', saveVehicle);

document.getElementById('importModalCloseBtn').addEventListener('click', closeImportModal);
document.getElementById('importCancelBtn').addEventListener('click', closeImportModal);
document.getElementById('importConfirmBtn').addEventListener('click', importData);

document.getElementById('previewCloseBtn').addEventListener('click', closePreviewModal);

document.addEventListener('keydown', async (e) => {
    if (e.key === 'Escape') {
        if (!vehicleModal.classList.contains('hidden')) {
            closeVehicleModal();
        } else if (!importModal.classList.contains('hidden')) {
            closeImportModal();
        } else if (!previewModal.classList.contains('hidden')) {
            closePreviewModal();
        } else {
            await post('close');
        }
    }
});

/* ===================================================== */
/*                  INITIALIZATION                        */
/* ===================================================== */

console.log('Vehicle Images Manager - UI Loaded');