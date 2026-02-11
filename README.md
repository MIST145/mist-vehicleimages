# 🚗 MH Vehicle Images V2

<p align="center">
    <img src="https://img.shields.io/badge/Version-2.0.0-blue?style=for-the-badge" />
    <img src="https://img.shields.io/badge/FiveM-Ready-success?style=for-the-badge" />
    <img src="https://img.shields.io/badge/License-GPL-black?style=for-the-badge" />
</p>

Sistema avançado de gestão dinâmica de imagens de veículos para FiveM com interface NUI completa, sistema de cache, e exports universais.

---

## 📋 **Índice**

- [Características](#-características)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Comandos](#-comandos)
- [Exports](#-exports)
- [Interface NUI](#-interface-nui)
- [Exemplos de Uso](#-exemplos-de-uso)
- [Migração](#-migração)
- [Troubleshooting](#-troubleshooting)
- [Créditos](#-créditos)

---

## ✨ **Características**

### 🎯 **Core Features**
- ✅ **Sistema Dinâmico**: Adicionar, editar e eliminar veículos sem restart
- ✅ **Interface NUI**: Menu completo em jogo com design moderno
- ✅ **Cache Inteligente**: Sistema de cache client/server para performance
- ✅ **URLs Remotas**: Suporte para GitHub, Imgur, Discord, Cloudinary
- ✅ **Sem Ficheiros Físicos**: Apenas URLs, economia de espaço
- ✅ **Categorização**: Organização por categorias de veículos
- ✅ **Pesquisa Rápida**: Sistema de pesquisa em tempo real
- ✅ **Import/Export**: Importar e exportar base de dados JSON
- ✅ **Permissões**: Sistema de permissões para admins
- ✅ **Multi-idioma**: Suporte PT, EN, ES, FR

### 🛠️ **Funcionalidades Avançadas**
- Sistema de backup automático
- Validação de URLs
- Preview de imagens em tempo real
- Notificações visuais
- Context menu (botão direito)
- Paginação inteligente
- Estatísticas em tempo real
- Logs detalhados (opcional)
- Webhook Discord (opcional)

---

## 📦 **Instalação**

### 1️⃣ **Download**
```bash
git clone https://github.com/MaDHouSe79/mist-vehicleimages
```

### 2️⃣ **Colocar na pasta resources**
```
resources/
└── [local]/
    └── mist-vehicleimages/
        ├── client/
        ├── server/
        ├── nui/
        ├── data/
        ├── config.lua
        └── fxmanifest.lua
```

### 3️⃣ **Adicionar ao server.cfg**
```cfg
ensure mist-vehicleimages
```

### 4️⃣ **Importar dados existentes** (opcional)
Se tens dados do sistema antigo ou do ficheiro JSON fornecido:
1. Coloca o ficheiro JSON em `data/vehicles.json`
2. Ou usa o comando `/vehimport` in-game

---

## ⚙️ **Configuração**

Edita `config.lua` para personalizar o sistema:

### 📊 **Configurações Principais**

```lua
Config.StorageType = 'json' -- 'json' ou 'mysql' (futuro)
Config.Language = 'pt' -- 'pt', 'en', 'es', 'fr'
Config.Debug = false -- Ativar logs de debug
```

### 🔐 **Permissões**

```lua
Config.UsePermissions = true
Config.AdminGroups = {
    'admin',
    'mod',
    'superadmin'
}
Config.AllowPublicView = true -- Todos podem ver
Config.AllowPublicPreview = true -- Todos podem usar /vehimg
```

### 🎨 **Interface**

```lua
Config.UI = {
    theme = 'dark', -- 'dark' ou 'light'
    accentColor = '#3b82f6',
    maxItemsPerPage = 50,
    showCategories = true,
    showSearch = true
}
```

### 🖼️ **Imagens**

```lua
Config.Images = {
    placeholder = 'https://via.placeholder.com/400x300',
    fallbackOnError = true,
    allowedDomains = {
        'raw.githubusercontent.com',
        'i.imgur.com',
        'cdn.discordapp.com'
    },
    validateUrls = true
}
```

---

## 🎮 **Comandos**

| Comando | Descrição | Permissão |
|---------|-----------|-----------|
| `/vehicleimages` | Abrir menu de gestão | Admin ou Public |
| `/vehimg [modelo]` | Preview rápido de veículo | Admin ou Public |
| `/vehimport` | Abrir modal de importação | Admin |
| `/vehexport` | Exportar base de dados | Admin |
| `/vehreload` | Recarregar base de dados | Admin |

**Comandos de Debug** (se `Config.Debug = true`):
- `/vehtest [modelo]` - Testar obtenção de imagem
- `/vehcache` - Ver estado do cache
- `/vehclear` - Limpar cache

---

## 🔌 **Exports**

### **Client-Side Exports**

#### 🎯 **Export Principal**
```lua
-- Obter URL de imagem de um veículo
local imageUrl = exports['mist-vehicleimages']:GetVehicleImage('adder')
-- Retorna: "https://..." ou placeholder
```

#### 📋 **Exports Completos**

```lua
-- Verificar se veículo tem imagem
local hasImage = exports['mist-vehicleimages']:HasVehicleImage('adder')

-- Obter todos os veículos
local allVehicles = exports['mist-vehicleimages']:GetAllVehicles()

-- Obter veículos por categoria
local superCars = exports['mist-vehicleimages']:GetVehiclesByCategory('super')

-- Pesquisar veículos
local results = exports['mist-vehicleimages']:SearchVehicles('adder')

-- Obter informação completa
local info = exports['mist-vehicleimages']:GetVehicleInfo('adder')
-- Retorna: {exists, model, url, category, custom, addedBy, addedAt}

-- Controle do menu
exports['mist-vehicleimages']:OpenMenu()
exports['mist-vehicleimages']:CloseMenu()
exports['mist-vehicleimages']:ToggleMenu()
local isOpen = exports['mist-vehicleimages']:IsMenuOpen()

-- Cache
exports['mist-vehicleimages']:ClearCache()
local cacheSize = exports['mist-vehicleimages']:GetCacheSize()

-- Utilitários
local total = exports['mist-vehicleimages']:GetTotalVehicles()
local isCustom = exports['mist-vehicleimages']:IsCustomVehicle('adder')
```

### **Server-Side Exports**

```lua
-- Obter URL de imagem
local imageUrl = exports['mist-vehicleimages']:GetVehicleImage('adder')

-- Obter todos os veículos
local allVehicles = exports['mist-vehicleimages']:GetAllVehicles()

-- Obter por categoria
local results = exports['mist-vehicleimages']:GetVehiclesByCategory('super')

-- Adicionar veículo
local success, vehicle = exports['mist-vehicleimages']:AddVehicle({
    name = 'customcar.png',
    url = 'https://...',
    category = 'custom',
    custom = true
})

-- Atualizar veículo
local success, vehicle = exports['mist-vehicleimages']:UpdateVehicle('adder', {
    url = 'https://new-url.com/adder.png',
    category = 'super'
})

-- Eliminar veículo
local success = exports['mist-vehicleimages']:DeleteVehicle('adder')

-- Estatísticas
local stats = exports['mist-vehicleimages']:GetStats()
```

---

## 🖥️ **Interface NUI**

### **Funcionalidades da Interface**

#### 🔍 **Pesquisa e Filtros**
- Barra de pesquisa em tempo real
- Filtro por categoria
- Paginação automática (50 items por página)
- Estatísticas dinâmicas

#### ➕ **Adicionar Veículo** (Admin)
1. Clica em "Adicionar"
2. Preenche:
   - Nome do modelo (spawn name)
   - URL da imagem
   - Categoria
   - Checkbox "Custom" (opcional)
3. Preview automático da imagem
4. Guardar

#### ✏️ **Editar Veículo** (Admin)
- Clica no botão "Editar" no card
- Ou clica com botão direito → Editar
- Modifica os campos desejados
- Guardar

#### 🗑️ **Eliminar Veículo** (Admin)
- Clica no botão "Eliminar" no card
- Ou clica com botão direito → Eliminar
- Confirmação de segurança

#### 📥 **Importar Dados** (Admin)
1. Clica em "Importar"
2. Cola o JSON no campo
3. Escolhe se quer sobrescrever dados existentes
4. Confirmar (cria backup automático)

#### 📤 **Exportar Dados** (Admin)
- Clica em "Exportar"
- Ficheiro JSON é baixado automaticamente
- Nome: `vehicles_export_[timestamp].json`

---

## 💡 **Exemplos de Uso**

### **Exemplo 1: Garagem**
```lua
-- client/garage.lua
local vehicles = exports['mist-vehicleimages']:GetAllVehicles()

for _, vehicle in ipairs(vehicles) do
    local model = vehicle.name:gsub('.png', '')
    local imageUrl = vehicle.url
    
    SendNUIMessage({
        action = 'addVehicle',
        data = {
            name = GetDisplayNameFromVehicleModel(model),
            image = imageUrl,
            price = 50000
        }
    })
end
```

### **Exemplo 2: Loja de Veículos**
```lua
-- client/shop.lua
RegisterNetEvent('shop:showVehicle', function(model)
    local imageUrl = exports['mist-vehicleimages']:GetVehicleImage(model)
    
    SendNUIMessage({
        action = 'showPreview',
        vehicle = {
            model = model,
            image = imageUrl
        }
    })
end)
```

### **Exemplo 3: Menu HTML**
```javascript
// nui/script.js
const model = 'adder';
const imageUrl = await fetch(`https://${GetParentResourceName()}/getImage`, {
    method: 'POST',
    body: JSON.stringify({model: model})
}).then(r => r.json());

document.getElementById('vehicle-img').src = imageUrl;
```

### **Exemplo 4: Notificação com Imagem**
```lua
-- client/notifications.lua
local function ShowVehicleNotification(model, message)
    local imageUrl = exports['mist-vehicleimages']:GetVehicleImage(model)
    
    SendNUIMessage({
        action = 'notify',
        image = imageUrl,
        message = message
    })
end

ShowVehicleNotification('adder', 'Compraste um Adder!')
```

---

## 🔄 **Migração**

### **Do Sistema Antigo (mh-vehicleimages)**

#### Método 1: Importação Manual
1. Para o servidor
2. Copia os ficheiros PNG de `mh-vehicleimages/images/`
3. Faz upload para GitHub/Imgur/Discord
4. Cria JSON com as URLs
5. Importa via `/vehimport`

#### Método 2: Script Automático
```lua
-- migration.lua
local oldPath = 'mh-vehicleimages/images/'
local newData = {pictures = {}}

for _, file in ipairs(GetFilesInDirectory(oldPath)) do
    if file:match('%.png$') then
        local model = file:gsub('.png', '')
        table.insert(newData.pictures, {
            name = file,
            url = 'YOUR_URL_BASE/' .. file,
            category = 'other',
            custom = false
        })
    end
end

-- Guardar newData como JSON
```

### **Compatibilidade**
O novo sistema mantém compatibilidade com o export antigo:
```lua
-- Funciona em ambos os sistemas
local image = exports['mist-vehicleimages']:GetImage('adder')
```

---

## 🐛 **Troubleshooting**

### **Problemas Comuns**

#### ❌ **Menu não abre**
```lua
-- Verifica permissões
Config.AllowPublicView = true -- No config.lua

-- Ou adiciona permissão ACE
add_ace group.admin vehicleimages.access allow
```

#### ❌ **Imagens não carregam**
```lua
-- Verifica URLs permitidas
Config.Images.allowedDomains = {} -- Permite todos
-- Ou adiciona domínio específico
```

#### ❌ **Erro ao importar JSON**
- Verifica formato do JSON
- Deve ter estrutura: `{"pictures": [...]}`
- Cada veículo deve ter `name` e `url`

#### ❌ **Performance lenta**
```lua
Config.Cache.enabled = true
Config.Cache.clientTTL = 3600
Config.UI.maxItemsPerPage = 25 -- Reduz items por página
```

### **Comandos de Debug**
```lua
Config.Debug = true -- Ativar logs
/vehcache -- Ver cache
/vehclear -- Limpar cache
/vehtest adder -- Testar veículo
```

---

## 📊 **Performance**

### **Benchmarks**
- **Resmon Idle**: ~0.01ms
- **Resmon Active (Menu)**: ~0.05ms
- **Tamanho do Resource**: ~500KB
- **Veículos Suportados**: Ilimitado
- **Tempo de Carregamento**: <1s (1000 veículos)

### **Otimizações**
- ✅ Sistema de cache multinível
- ✅ Lazy loading de imagens
- ✅ Paginação inteligente
- ✅ Debounce em pesquisas
- ✅ Sem ficheiros físicos

---

## 📝 **Formato de Dados**

### **Estrutura JSON**
```json
{
  "pictures": [
    {
      "name": "adder.png",
      "url": "https://raw.githubusercontent.com/.../adder.png",
      "category": "super",
      "custom": false,
      "addedBy": "Admin",
      "addedAt": 1234567890,
      "editedBy": "Admin",
      "editedAt": 1234567890
    }
  ]
}
```

### **Categorias Disponíveis**
- `super` - Super Carros
- `sports` - Desportivos
- `sportsclassics` - Clássicos Desportivos
- `sedans` - Sedans
- `coupes` - Coupés
- `muscle` - Muscle
- `offroad` - Todo-o-Terreno
- `suvs` - SUVs
- `vans` - Carrinhas
- `motorcycles` - Motas
- `planes` - Aviões
- `helicopters` - Helicópteros
- `boats` - Barcos
- `industrial` - Industrial
- `utility` - Utilitários
- `emergency` - Emergência
- `military` - Militar
- `commercial` - Comercial
- `custom` - Custom
- `other` - Outros

---

## 🎨 **Personalização**

### **Cores**
Edita `nui/style.css`:
```css
:root {
    --primary: #3b82f6; /* Cor principal */
    --bg-dark: #111827; /* Fundo escuro */
    --bg-card: #1f2937; /* Fundo dos cards */
}
```

### **Traduções**
Adiciona idioma em `config.lua`:
```lua
Config.Translations.es = {
    menu_title = 'Gestión de Imágenes',
    -- ...
}
```

---

## 🤝 **Contribuir**

1. Fork o projeto
2. Cria um branch (`git checkout -b feature/NovaFeature`)
3. Commit mudanças (`git commit -m 'Add NovaFeature'`)
4. Push para o branch (`git push origin feature/NovaFeature`)
5. Abre um Pull Request

---

## 📜 **Licença**

GPL License - Vê [LICENSE](./LICENSE) para detalhes

---

## 👨‍💻 **Créditos**

**Desenvolvido por:** [MaDHouSe79](https://github.com/MaDHouSe79)  
**YouTube:** [@MaDHouSe79](https://www.youtube.com/@MaDHouSe79)  
**Versão:** 2.0.0  
**Última Atualização:** 2025

---

## 📞 **Suporte**

- 🐛 **Issues:** [GitHub Issues](https://github.com/MaDHouSe79/mist-vehicleimages/issues)
- 💬 **Discord:** [Link do Discord]
- 📺 **YouTube:** [MaDHouSe79 Channel](https://www.youtube.com/@MaDHouSe79)

---

<p align="center">
    <strong>⭐ Se gostaste, deixa uma estrela no GitHub! ⭐</strong>
</p>
