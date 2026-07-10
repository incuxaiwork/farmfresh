// Global State Management
const STATE = {
    products: [
        {
            id: 'prod-1',
            name: 'Organic Vegetables Basket',
            price: 7.20,
            originalPrice: 12.00,
            discount: '40% OFF',
            origin: 'Santorini, Greece',
            category: 'vegetables',
            image: 'assets/basket_vegetables.jpg',
            description: 'Fresh hand-harvested organic vegetables directly from Santorini fields. A healthy mix of vine-ripened tomatoes, cucumbers, peppers, and green lettuce. Raised without pesticides.',
            calories: '320 kcal',
            protein: '12 gram',
            fat: '15 gram',
            weight: '1.5 Kg'
        },
        {
            id: 'prod-2',
            name: 'Crisp Red Apples',
            price: 3.99,
            originalPrice: 4.99,
            discount: '20% OFF',
            origin: 'Washington, US',
            category: 'fruits',
            image: 'assets/crisp_red_apples.jpg',
            description: 'Deliciously sweet and crispy red delicious apples. Perfect for a healthy afternoon snack or baking apple pies. Handpicked with quality checks.',
            calories: '150 kcal',
            protein: '2 gram',
            fat: '0 gram',
            weight: '1.0 Kg'
        },
        {
            id: 'prod-3',
            name: 'Fresh English Cucumbers',
            price: 2.99,
            originalPrice: 4.29,
            discount: '30% OFF',
            origin: 'Crete, Greece',
            category: 'vegetables',
            image: 'assets/english_cucumbers.jpg',
            description: 'Cool and refreshing green cucumbers. Highly hydrating and crunchy, perfect for salads, dipping, or dynamic Greek tzatziki yogurt dip.',
            calories: '45 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.8 Kg'
        },
        {
            id: 'prod-4',
            name: 'Premium Ribeye Steak',
            price: 18.99,
            originalPrice: 18.99,
            discount: null,
            origin: 'Texas, US',
            category: 'meat',
            image: 'assets/ribeye_steak.jpg',
            description: 'Thick, beautifully marbled grade-A beef ribeye steak. Perfectly tender and juicy, ideal for pan-searing or grilling over wood fire.',
            calories: '820 kcal',
            protein: '64 gram',
            fat: '52 gram',
            weight: '0.5 Kg'
        },
        {
            id: 'prod-5',
            name: 'Organic Whole Milk',
            price: 3.49,
            originalPrice: 3.49,
            discount: null,
            origin: 'Wisconsin, US',
            category: 'dairy',
            image: 'assets/organic_whole_milk.jpg',
            description: 'Creamy, farm-fresh pasteurized organic whole milk. Produced by grass-fed dairy cows, packed with rich vitamins and high calcium.',
            calories: '280 kcal',
            protein: '16 gram',
            fat: '18 gram',
            weight: '1.0 L'
        },
        {
            id: 'prod-6',
            name: 'Fresh Farm Eggs',
            price: 4.50,
            originalPrice: 4.50,
            discount: null,
            origin: 'Ohio, US',
            category: 'dairy',
            image: 'assets/fresh_farm_eggs.jpg',
            description: 'One dozen pasture-raised organic brown eggs. Rich yellow yolks, collected daily from free-range hens.',
            calories: '180 kcal',
            protein: '14 gram',
            fat: '12 gram',
            weight: '0.7 Kg'
        },
        {
            id: 'prod-7',
            name: 'Sweet Organic Strawberries',
            price: 4.99,
            originalPrice: 5.99,
            discount: '16% OFF',
            origin: 'California, US',
            category: 'fruits',
            image: 'assets/organic_strawberries.jpg',
            description: 'Plump, juicy, sweet organic strawberries freshly picked from sunny berry patches. Loaded with vitamin C.',
            calories: '80 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.4 Kg'
        },
        {
            id: 'prod-8',
            name: 'Fresh Hass Avocados',
            price: 5.49,
            originalPrice: 6.99,
            discount: '21% OFF',
            origin: 'Michoacan, Mexico',
            category: 'fruits',
            image: 'assets/hass_avocados.jpg',
            description: 'Creamy Hass avocados with rich nutty flavor. Perfectly ripe and ready to mash for fresh guacamole or spread on morning toast.',
            calories: '320 kcal',
            protein: '4 gram',
            fat: '29 gram',
            weight: '0.6 Kg'
        },
        {
            id: 'prod-9',
            name: 'Baby Spinach Leaves',
            price: 2.49,
            originalPrice: 2.49,
            discount: null,
            origin: 'Arizona, US',
            category: 'vegetables',
            image: 'assets/baby_spinach.jpg',
            description: 'Tender, pre-washed organic baby spinach leaves. Perfect for salads, healthy green smoothies, or sautéing.',
            calories: '20 kcal',
            protein: '2 gram',
            fat: '0 gram',
            weight: '0.3 Kg'
        },
        {
            id: 'prod-10',
            name: 'Organic Carrots Bunch',
            price: 1.99,
            originalPrice: 2.79,
            discount: '28% OFF',
            origin: 'Oregon, US',
            category: 'vegetables',
            image: 'assets/organic_carrots.jpg',
            description: 'Sweet and crunchy farm-fresh orange carrots with leafy tops still attached. High in beta-carotene.',
            calories: '90 kcal',
            protein: '2 gram',
            fat: '0 gram',
            weight: '0.5 Kg'
        },
        {
            id: 'prod-11',
            name: 'Free-Range Chicken Breast',
            price: 9.99,
            originalPrice: 11.99,
            discount: '16% OFF',
            origin: 'Georgia, US',
            category: 'meat',
            image: 'assets/chicken_breast.jpg',
            description: 'Tender, boneless and skinless free-range chicken breasts. Locally sourced from pasture-fed poultry farms.',
            calories: '450 kcal',
            protein: '92 gram',
            fat: '10 gram',
            weight: '0.8 Kg'
        },
        {
            id: 'prod-12',
            name: 'Artisanal Goat Cheese',
            price: 6.20,
            originalPrice: 6.20,
            discount: null,
            origin: 'Vermont, US',
            category: 'dairy',
            image: 'assets/goat_cheese.jpg',
            description: 'Soft, creamy artisanal goat cheese log with a mild, tangy finish. Hand-crafted locally in small batches.',
            calories: '310 kcal',
            protein: '18 gram',
            fat: '26 gram',
            weight: '0.2 Kg'
        },
        {
            id: 'prod-13',
            name: 'Juicy Organic Oranges',
            price: 3.80,
            originalPrice: 4.80,
            discount: '20% OFF',
            origin: 'Florida, US',
            category: 'fruits',
            image: 'assets/organic_oranges.jpg',
            description: 'Sweet and tangy seedless organic oranges with rich juice content. Locally grown in sunshine citrus groves.',
            calories: '110 kcal',
            protein: '2 gram',
            fat: '0 gram',
            weight: '1.2 Kg'
        },
        {
            id: 'prod-14',
            name: 'Fresh Blueberries Pint',
            price: 4.49,
            originalPrice: 4.49,
            discount: null,
            origin: 'Michigan, US',
            category: 'fruits',
            image: 'assets/fresh_blueberries.jpg',
            description: 'Plump, antioxidant-rich fresh blueberries. Ideal for healthy baking, fruit salads, pancakes, or morning oatmeal.',
            calories: '70 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.3 Kg'
        },
        {
            id: 'prod-15',
            name: 'Organic Broccolini Bunch',
            price: 3.29,
            originalPrice: 4.49,
            discount: '26% OFF',
            origin: 'Salinas, US',
            category: 'vegetables',
            image: 'assets/organic_broccolini.jpg',
            description: 'Tender, sweet baby broccolini stalks. Perfect for healthy stir-frying, steaming, or roasting with olive oil.',
            calories: '45 kcal',
            protein: '3 gram',
            fat: '0 gram',
            weight: '0.4 Kg'
        },
        {
            id: 'prod-16',
            name: 'Sweet Cherry Tomatoes',
            price: 2.80,
            originalPrice: 3.99,
            discount: '30% OFF',
            origin: 'Sicily, Italy',
            category: 'vegetables',
            image: 'assets/cherry_tomatoes.jpg',
            description: 'Vibrant and sweet vine-ripened red cherry tomatoes. Ideal for roasting, salad dressings, or healthy snacking.',
            calories: '35 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.5 Kg'
        },
        {
            id: 'prod-17',
            name: 'Fresh Salmon Fillet',
            price: 14.99,
            originalPrice: 17.99,
            discount: '16% OFF',
            origin: 'Atlantic Waters',
            category: 'meat',
            image: 'assets/salmon_fillet.jpg',
            description: 'Wild-caught premium Atlantic salmon fillet. Rich in Omega-3 fatty acids, ideal for baking, grilling, or pan-searing.',
            calories: '480 kcal',
            protein: '46 gram',
            fat: '28 gram',
            weight: '0.4 Kg'
        },
        {
            id: 'prod-18',
            name: 'Salted Grass-Fed Butter',
            price: 4.80,
            originalPrice: 4.80,
            discount: null,
            origin: 'Wisconsin, US',
            category: 'dairy',
            image: 'assets/grassfed_butter.jpg',
            description: 'Rich and creamy golden butter churned from the milk of grass-fed pasture cows. Lightly salted.',
            calories: '720 kcal',
            protein: '1 gram',
            fat: '82 gram',
            weight: '0.25 Kg'
        },
        {
            id: 'prod-19',
            name: 'Sweet Red Cherries',
            price: 5.99,
            originalPrice: 7.99,
            discount: '25% OFF',
            origin: 'Oregon, US',
            category: 'fruits',
            image: 'assets/organic_strawberries.jpg',
            description: 'Sweet, juicy red cherries freshly harvested from hillside orchards. A perfect summer treat.',
            calories: '90 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.5 Kg'
        },
        {
            id: 'prod-20',
            name: 'Crunchy Romaine Lettuce',
            price: 2.20,
            originalPrice: 2.20,
            discount: null,
            origin: 'Salinas, US',
            category: 'vegetables',
            image: 'assets/baby_spinach.jpg',
            description: 'Crisp and fresh Romaine lettuce head. Excellent crunchy base for Caesar salads, burgers, or wraps.',
            calories: '15 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.4 Kg'
        },
        {
            id: 'prod-21',
            name: 'Premium Pork Rib Chop',
            price: 12.99,
            originalPrice: 15.99,
            discount: '18% OFF',
            origin: 'Iowa, US',
            category: 'meat',
            image: 'assets/ribeye_steak.jpg',
            description: 'Thick-cut bone-in pork rib chops. Tender and juicy, perfect for slow-roasting, pan-searing, or grilling.',
            calories: '540 kcal',
            protein: '38 gram',
            fat: '42 gram',
            weight: '0.6 Kg'
        },
        {
            id: 'prod-22',
            name: 'Artisanal Salted Butter',
            price: 4.99,
            originalPrice: 5.99,
            discount: '16% OFF',
            origin: 'Vermont, US',
            category: 'dairy',
            image: 'assets/grassfed_butter.jpg',
            description: 'Hand-rolled salted farm butter churned from premium grass-fed cream. Packed with rich, traditional dairy flavor.',
            calories: '750 kcal',
            protein: '1 gram',
            fat: '84 gram',
            weight: '0.25 Kg'
        },
        {
            id: 'prod-23',
            name: 'Farm Fresh Duck Eggs',
            price: 6.50,
            originalPrice: 6.50,
            discount: null,
            origin: 'Lancaster, US',
            category: 'dairy',
            image: 'assets/fresh_farm_eggs.jpg',
            description: 'Large pasture-raised fresh duck eggs. Rich creamy yolks, highly prized for baking and gourmet breakfast dishes.',
            calories: '220 kcal',
            protein: '16 gram',
            fat: '14 gram',
            weight: '0.8 Kg'
        },
        {
            id: 'prod-24',
            name: 'Seedless Clementines',
            price: 3.99,
            originalPrice: 4.99,
            discount: '20% OFF',
            origin: 'Valencia, Spain',
            category: 'fruits',
            image: 'assets/organic_oranges.jpg',
            description: 'Sweet, easy-to-peel seedless clementines. The perfect snack-sized fresh citrus fruit pack.',
            calories: '80 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '1.0 Kg'
        }
    ],
    categories: [
        { id: 'all', label: 'All', icon: '<i class="fa-solid fa-basket-shopping" style="color: #2E7D32;"></i>' },
        { id: 'fruits', label: 'Fruits', icon: '<i class="fa-solid fa-apple-whole" style="color: #E63946;"></i>' },
        { id: 'vegetables', label: 'Vegetables', icon: '<i class="fa-solid fa-carrot" style="color: #F4A261;"></i>' },
        { id: 'meat', label: 'Meat', icon: '<i class="fa-solid fa-drumstick-bite" style="color: #8D5B4C;"></i>' },
        { id: 'dairy', label: 'Dairy', icon: '<i class="fa-solid fa-cheese" style="color: #E28C43;"></i>' }
    ],
    cart: [],
    wishlist: [],
    orders: [],
    merchants: [
        { id: 'FARM-82', name: 'Organico Farm', earnings: 0.00, verified: true, activeOrders: 0 },
        { id: 'FARM-99', name: 'Valley Green Orchards', earnings: 0.00, verified: false, activeOrders: 0 }
    ],
    rider: {
        id: 'RIDER-45',
        name: 'Alex Rider',
        earnings: 0.00,
        trips: 0,
        activeOrderId: null
    },
    admin: {
        totalSales: 0.00,
        totalOrders: 0
    },
    activeCategory: 'all',
    searchQuery: '',
    selectedProductId: null,
    couponApplied: null,
    activePaymentMethod: 'gpay',
    selectedPaymentMode: 'upi',
    upiVerified: false,
    selectedWallet: 'paytm',
    cartSelectedPaymentMode: 'upi',
    cartUpiVerified: false,
    currentRole: 'customer',
    currentScreen: 'onboarding',
    userEmail: 'ritih@gmail.com'
};

// Currency State System
let currentCurrencySymbol = '$';
let currentCurrencyRate = 1.0;

function formatPrice(usdAmount) {
    const converted = usdAmount * currentCurrencyRate;
    return `${currentCurrencySymbol}${converted.toFixed(2)}`;
}

// Logger Utility
const Logger = {
    consoleEl: document.getElementById('logger-console-output'),
    log(message, role = 'system') {
        const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        const logItem = document.createElement('div');
        logItem.className = `log-entry ${role}`;
        logItem.innerHTML = `<span class="log-time">[${time}]</span> <span style="font-weight: 700;">${role.toUpperCase()}:</span> ${message}`;
        this.consoleEl.appendChild(logItem);
        this.consoleEl.scrollTop = this.consoleEl.scrollHeight;
    },
    clear() {
        this.consoleEl.innerHTML = '';
        this.log('Debugger session re-initialized.', 'system');
    }
};

// Push Notification Simulation
const Notification = {
    el: document.getElementById('mock-notification'),
    titleEl: document.getElementById('notif-title'),
    bodyEl: document.getElementById('notif-body'),
    show(title, message) {
        this.titleEl.innerText = title;
        this.bodyEl.innerText = message;
        this.el.classList.add('visible');
        
        // Dynamic sound/vibration feedback simulation
        if (navigator.vibrate) {
            navigator.vibrate([100, 50, 100]);
        }
        
        setTimeout(() => {
            this.el.classList.remove('visible');
        }, 5000);
    }
};

let toastTimeout = null;
function showToast(message) {
    const el = document.getElementById('toast-popup');
    if (!el) return;
    el.innerHTML = message;
    el.classList.add('show');
    
    if (toastTimeout) clearTimeout(toastTimeout);
    toastTimeout = setTimeout(() => {
        el.classList.remove('show');
    }, 2000);
}

// Dynamic Clock
function updateClock() {
    const timeEl = document.getElementById('phone-time');
    const now = new Date();
    timeEl.innerText = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
}
setInterval(updateClock, 1000);
updateClock();

// Routing & View Screen Control
function switchScreen(screenId, activeTabId = null) {
    const screens = document.querySelectorAll('.app-screen');
    screens.forEach(s => s.classList.remove('active'));
    
    const targetScreen = document.getElementById(screenId);
    if (targetScreen) {
        targetScreen.classList.add('active');
        // Reset scroll position
        targetScreen.scrollTop = 0;
        
        // Render wishlist if switching to wishlist screen
        if (screenId === 'screen-customer-wishlist') {
            renderWishlistScreen();
        }
        if (screenId === 'screen-customer-categories') {
            renderCategoriesScreen();
        }
        
        // Hide/show bottom nav bar based on screen
        const customerNav = document.getElementById('phone-bottom-navbar');
        const farmerNav = document.getElementById('farmer-bottom-navbar');
        const deliveryNav = document.getElementById('delivery-bottom-navbar');
        const statusBar = document.getElementById('phone-status-bar');
        
        // Hide all navbars initially
        customerNav.style.display = 'none';
        farmerNav.style.display = 'none';
        deliveryNav.style.display = 'none';

        if (screenId === 'screen-onboarding') {
            statusBar.classList.remove('dark-mode-icons');
        } else {
            // Show appropriate navbar based on role
            if (STATE.currentRole === 'customer') {
                customerNav.style.display = 'flex';
            } else if (STATE.currentRole === 'farmer') {
                farmerNav.style.display = 'flex';
            } else if (STATE.currentRole === 'delivery') {
                deliveryNav.style.display = 'flex';
            }
            statusBar.classList.add('dark-mode-icons');
        }
        
        // Update active tab styling
        updateActiveBottomTab(activeTabId || screenId);
    }
}

function updateActiveBottomTab(activeId) {
    const tabs = document.querySelectorAll('.nav-tab-item');
    tabs.forEach(t => {
        if (t) t.classList.remove('active');
    });
    
    if (activeId === 'tab-home' || activeId === 'screen-customer-home') {
        const el = document.getElementById('tab-home');
        if (el) el.classList.add('active');
    } else if (activeId === 'tab-categories') {
        const el = document.getElementById('tab-categories');
        if (el) el.classList.add('active');
    } else if (activeId === 'tab-cart' || activeId === 'screen-customer-cart') {
        const el = document.getElementById('tab-cart');
        if (el) el.classList.add('active');
    } else if (activeId === 'tab-tracking' || activeId === 'screen-customer-tracking') {
        const el = document.getElementById('tab-tracking');
        if (el) el.classList.add('active');
    } else if (activeId === 'screen-farmer-dashboard') {
        const el = document.getElementById('tab-farmer-dashboard');
        if (el) el.classList.add('active');
    } else if (activeId === 'screen-farmer-products') {
        const el = document.getElementById('tab-farmer-products');
        if (el) el.classList.add('active');
    } else if (activeId === 'screen-farmer-profile') {
        const el = document.getElementById('tab-farmer-profile');
        if (el) el.classList.add('active');
    } else if (activeId === 'screen-delivery-dashboard') {
        const el = document.getElementById('tab-delivery-dashboard');
        if (el) el.classList.add('active');
    } else if (activeId === 'screen-delivery-profile') {
        const el = document.getElementById('tab-delivery-profile');
        if (el) el.classList.add('active');
    }
}

// Role Switcher Control
function switchRole(role) {
    STATE.currentRole = role;
    
    // UI update for role buttons
    document.querySelectorAll('.role-btn').forEach(btn => btn.classList.remove('active'));
    document.getElementById(`btn-role-${role}`).classList.add('active');
    
    Logger.log(`Swapped simulator viewpoint to ${role.toUpperCase()}`, 'system');
    
    // View Switch matching the role
    if (role === 'customer') {
        switchScreen('screen-customer-home');
    } else if (role === 'farmer') {
        switchScreen('screen-farmer-dashboard');
        renderFarmerOrders();
        updateFarmerStats();
        renderFarmerInventory();
    } else if (role === 'delivery') {
        switchScreen('screen-delivery-dashboard');
        renderRiderDashboard();
    } else if (role === 'admin') {
        switchScreen('screen-admin-dashboard');
        renderAdminDashboard();
    }
}

// Rendering Category Filters
function renderCategories() {
    const container = document.getElementById('categories-container');
    container.innerHTML = STATE.categories.map(c => `
        <div class="category-pill ${STATE.activeCategory === c.id ? 'active' : ''}" onclick="selectCategory('${c.id}')">
            <div class="category-icon-circle">${c.icon}</div>
            <span class="label">${c.label}</span>
        </div>
    `).join('');
}

function selectCategory(catId) {
    STATE.activeCategory = catId;
    renderCategories();
    renderProducts();
    Logger.log(`Filtered store products by category: "${catId}"`, 'customer');
}

// Rendering Products Grid
function renderProducts() {
    const container = document.getElementById('products-grid-container');
    
    // Filter logic
    let filtered = STATE.products;
    if (STATE.activeCategory !== 'all') {
        filtered = filtered.filter(p => p.category === STATE.activeCategory);
    }
    if (STATE.searchQuery.trim() !== '') {
        filtered = filtered.filter(p => p.name.toLowerCase().includes(STATE.searchQuery.toLowerCase()));
    }
    
    if (filtered.length === 0) {
        container.innerHTML = '<div style="grid-column: span 2; text-align:center; padding: 20px; color:var(--text-muted); font-size:12px;">No products found.</div>';
        return;
    }

    container.innerHTML = filtered.map(p => {
        const isDetailsImage = p.image.endsWith('.jpg');
        const imgContent = isDetailsImage 
            ? `<img src="${p.image}" alt="${p.name}">` 
            : `<div class="svg-placeholder">${p.image}</div>`;

        const inWishlist = STATE.wishlist.includes(p.id);
        const activeClass = inWishlist ? 'active' : '';
        const basketColor = inWishlist ? 'var(--primary)' : '#cbd5e1';
        const basketIcon = `<i class="fa-solid fa-basket-shopping" style="color: ${basketColor};"></i>`;

        return `
            <div class="product-card" onclick="viewProductDetails('${p.id}')">
                ${p.discount ? `<span class="discount-tag">${p.discount}</span>` : ''}
                <button class="product-wishlist-btn ${activeClass}" onclick="toggleWishlist(event, '${p.id}')">
                    ${basketIcon}
                </button>
                <div class="product-image-container">
                    ${imgContent}
                </div>
                <div class="product-title">${p.name}</div>
                <div class="product-meta-row">
                    <span class="product-price">${formatPrice(p.price)}</span>
                    <div class="product-card-add-btn" onclick="addToCart(event, '${p.id}')">
                        <i class="fa-solid fa-plus"></i>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

// BASKET ANIMATION confettis
function createBasketParticles(btn) {
    const viewport = document.getElementById('app-viewport');
    if (!viewport || !btn) return;
    
    const rect = btn.getBoundingClientRect();
    const viewRect = viewport.getBoundingClientRect();
    
    const xCenter = rect.left - viewRect.left + (rect.width / 2);
    const yCenter = rect.top - viewRect.top + (rect.height / 2);
    
    const particleCount = 8;
    for (let i = 0; i < particleCount; i++) {
        const p = document.createElement('div');
        p.className = 'basket-particle';
        p.innerHTML = '<i class="fa-solid fa-basket-shopping"></i>';
        
        const angle = Math.random() * Math.PI * 2;
        const dist = 15 + Math.random() * 25;
        const xOffset = Math.cos(angle) * dist;
        const yOffset = Math.sin(angle) * dist;
        const rot = (Math.random() - 0.5) * 360;
        
        p.style.setProperty('--x', `${xOffset}px`);
        p.style.setProperty('--y', `${yOffset}px`);
        p.style.setProperty('--rot', `${rot}deg`);
        
        p.style.left = `${xCenter}px`;
        p.style.top = `${yCenter}px`;
        
        viewport.appendChild(p);
        
        setTimeout(() => p.remove(), 800);
    }
}

// TOGGLE WISHLIST ACTION
window.toggleWishlist = function(e, prodId) {
    if (e) e.stopPropagation();
    
    const prod = STATE.products.find(p => p.id === prodId);
    if (!prod) return;
    
    const index = STATE.wishlist.indexOf(prodId);
    
    if (index === -1) {
        STATE.wishlist.push(prodId);
        showToast(`Saved ${prod.name} to My Basket! 🧺`);
        Logger.log(`Saved product "${prod.name}" to customer basket wishlist.`, 'customer');
        
        // Trigger particle animation on the clicked element
        if (e && e.currentTarget) {
            createBasketParticles(e.currentTarget);
        }
    } else {
        STATE.wishlist.splice(index, 1);
        showToast(`Removed ${prod.name} from My Basket! 🗑️`);
        Logger.log(`Removed product "${prod.name}" from customer basket wishlist.`, 'customer');
    }
    
    updateWishlistBadge();
    renderProducts();
    
    // If the wishlist screen is active, re-render it
    if (document.getElementById('screen-customer-wishlist').classList.contains('active')) {
        renderWishlistScreen();
    }
};

// UPDATE WISHLIST BADGE
function updateWishlistBadge() {
    const badge = document.getElementById('wishlist-badge-count');
    if (!badge) return;
    
    const count = STATE.wishlist.length;
    if (count > 0) {
        badge.innerText = count;
        badge.style.display = 'flex';
    } else {
        badge.style.display = 'none';
    }
}

// RENDER MY WISHLIST SCREEN
window.renderWishlistScreen = function() {
    const listContainer = document.getElementById('wishlist-items-list');
    const emptyState = document.getElementById('wishlist-empty-state');
    
    if (!listContainer || !emptyState) return;
    
    if (STATE.wishlist.length === 0) {
        listContainer.innerHTML = '';
        emptyState.style.display = 'block';
        return;
    }
    
    emptyState.style.display = 'none';
    
    listContainer.innerHTML = STATE.wishlist.map(prodId => {
        const p = STATE.products.find(item => item.id === prodId);
        if (!p) return '';
        
        const isDetailsImage = p.image.endsWith('.jpg');
        const imgContent = isDetailsImage 
            ? `<img class="wishlist-item-img" src="${p.image}" alt="${p.name}">` 
            : `<div class="wishlist-item-img" style="display:flex; align-items:center; justify-content:center; font-size:24px; background:#F1F8F4; border:1px solid rgba(46,125,50,0.05);">${p.image}</div>`;
            
        return `
            <div class="wishlist-item-card">
                ${imgContent}
                <div class="wishlist-item-info">
                    <span class="wishlist-item-name">${p.name}</span>
                    <span class="wishlist-item-origin">${p.origin}</span>
                    <span class="wishlist-item-price">${formatPrice(p.price)}</span>
                </div>
                <div class="wishlist-item-actions">
                    <button class="btn-wishlist-cart" onclick="addWishlistItemToCart('${p.id}')">
                        Add to Cart
                    </button>
                    <button class="btn-wishlist-remove" onclick="toggleWishlist(null, '${p.id}')">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </div>
            </div>
        `;
    }).join('');
};

// ADD WISHLIST ITEM TO CART DIRECTLY
window.addWishlistItemToCart = function(prodId) {
    const prod = STATE.products.find(p => p.id === prodId);
    if (!prod) return;
    
    const existing = STATE.cart.find(item => item.productId === prodId);
    if (existing) {
        existing.quantity += 1;
    } else {
        STATE.cart.push({ productId: prodId, quantity: 1 });
    }
    
    // Auto-remove from wishlist/basket
    const idx = STATE.wishlist.indexOf(prodId);
    if (idx !== -1) {
        STATE.wishlist.splice(idx, 1);
        updateWishlistBadge();
    }
    
    updateCartStats();
    showToast(`Added ${prod.name} to Cart! 🛒`);
    Logger.log(`Added wishlisted product "${prod.name}" to cart & removed from saved basket.`, 'customer');
    
    // Refresh UI
    renderProducts();
    renderWishlistScreen();
};

// VIEW PRODUCT DETAILS
window.viewProductDetails = function(prodId) {
    STATE.selectedProductId = prodId;
    const product = STATE.products.find(p => p.id === prodId);
    
    if (!product) return;
    
    document.getElementById('details-product-title').innerText = product.name;
    document.getElementById('details-product-price').innerText = formatPrice(product.price);
    document.getElementById('details-product-origin').innerText = product.origin;
    document.getElementById('details-product-desc').innerText = product.description;
    
    document.getElementById('nutrition-calories').innerText = product.calories;
    document.getElementById('nutrition-protein').innerText = product.protein;
    document.getElementById('nutrition-fat').innerText = product.fat;
    document.getElementById('nutrition-weight').innerText = product.weight;
    
    const imgEl = document.getElementById('details-product-img');
    if (product.image.endsWith('.jpg')) {
        imgEl.src = product.image;
        imgEl.style.display = 'block';
    } else {
        // Fallback for emoji icons
        imgEl.src = `https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(product.name)}&backgroundColor=c5e1a5`;
    }
    
    // Update Details Wishlist button state
    const detailWishBtn = document.getElementById('btn-details-wishlist-toggle');
    if (detailWishBtn) {
        const updateDetailBtnIcon = (isActive) => {
            detailWishBtn.innerHTML = isActive 
                ? '<i class="fa-solid fa-basket-shopping" style="color: var(--primary);"></i>' 
                : '<i class="fa-solid fa-basket-shopping" style="color: var(--green-dark); opacity: 0.5;"></i>';
        };
        
        updateDetailBtnIcon(STATE.wishlist.includes(prodId));
        
        detailWishBtn.onclick = (e) => {
            toggleWishlist(null, prodId);
            updateDetailBtnIcon(STATE.wishlist.includes(prodId));
            // Trigger animation on detail toggle button
            createBasketParticles(detailWishBtn);
        };
    }
    
    switchScreen('screen-customer-details');
    Logger.log(`Inspected product detail details page: "${product.name}"`, 'customer');
};

// CART LOGIC
window.addToCart = function(e, prodId) {
    if (e) e.stopPropagation();
    
    const product = STATE.products.find(p => p.id === prodId);
    const existing = STATE.cart.find(item => item.productId === prodId);
    
    if (existing) {
        existing.quantity += 1;
    } else {
        STATE.cart.push({ productId: prodId, quantity: 1 });
    }
    
    // Auto-remove from wishlist/basket
    const idx = STATE.wishlist.indexOf(prodId);
    if (idx !== -1) {
        STATE.wishlist.splice(idx, 1);
        updateWishlistBadge();
        
        // Update Details button state if open
        const detailWishBtn = document.getElementById('btn-details-wishlist-toggle');
        if (detailWishBtn && STATE.selectedProductId === prodId) {
            detailWishBtn.innerHTML = '<i class="fa-solid fa-basket-shopping" style="color: var(--green-dark); opacity: 0.5;"></i>';
        }
    }
    
    Logger.log(`Added "${product.name}" to cart (Quantity: ${existing ? existing.quantity : 1}) & removed from saved basket.`, 'customer');
    updateCartStats();
    Notification.show('Added to Cart', `${product.name} has been added to your shopping cart.`);
    showToast('Added to Cart! 🛒');
    
    // Refresh UI
    renderProducts();
    if (document.getElementById('screen-customer-wishlist').classList.contains('active')) {
        renderWishlistScreen();
    }
};

function updateCartStats() {
    const totalItems = STATE.cart.reduce((sum, item) => sum + item.quantity, 0);
    document.getElementById('cart-item-badge').innerText = `${totalItems} items`;
    
    // Update Onboarding screen mockup tags to match cart total for visual immersion
    if (totalItems > 0) {
        document.getElementById('onboard-items-count').innerText = totalItems;
        let sub = STATE.cart.reduce((sum, item) => {
            const p = STATE.products.find(prod => prod.id === item.productId);
            return sum + (p.price * item.quantity);
        }, 0);
        document.getElementById('onboard-total-price').innerText = formatPrice(sub + 3.99);
    }
    
    renderCart();
}

function renderCart() {
    const container = document.getElementById('cart-items-list-container');
    
    if (STATE.cart.length === 0) {
        container.innerHTML = '<div class="cart-empty-message">Your shopping cart is currently empty. Add fresh items from the store!</div>';
        updateCartTotals();
        return;
    }

    container.innerHTML = STATE.cart.map(item => {
        const prod = STATE.products.find(p => p.id === item.productId);
        const imageHtml = prod.image.endsWith('.jpg') 
            ? `<img class="cart-item-img" src="${prod.image}" alt="${prod.name}">` 
            : `<div class="cart-item-img" style="display:flex;align-items:center;justify-content:center;font-size:24px;background:#EAF6EC;">${prod.image}</div>`;

        return `
            <div class="cart-item-card">
                ${imageHtml}
                <div class="cart-item-details">
                    <div class="cart-item-name">${prod.name}</div>
                    <div class="cart-item-price">${formatPrice(prod.price)}</div>
                </div>
                <div class="cart-item-actions">
                    <div class="quantity-control">
                        <button class="quantity-btn" onclick="updateQty('${prod.id}', -1)">-</button>
                        <span class="quantity-val">${item.quantity}</span>
                        <button class="quantity-btn" onclick="updateQty('${prod.id}', 1)">+</button>
                    </div>
                    <div style="display:flex; gap:10px; align-items:center; margin-top:2px;">
                        <button class="cart-item-basket-btn" onclick="moveCartItemToBasket(event, '${prod.id}')" title="Move to Saved Basket" style="border: none; background: transparent; color: var(--primary); font-size: 11px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: transform 0.1s ease;">
                            <i class="fa-solid fa-basket-shopping"></i>
                        </button>
                        <button class="cart-item-remove-btn" onclick="removeCartItem('${prod.id}')">Remove</button>
                    </div>
                </div>
            </div>
        `;
    }).join('');
    
    updateCartTotals();
}

window.updateQty = function(prodId, delta) {
    const item = STATE.cart.find(i => i.productId === prodId);
    if (!item) return;
    
    item.quantity += delta;
    if (item.quantity <= 0) {
        removeCartItem(prodId);
    } else {
        updateCartStats();
    }
};

window.removeCartItem = function(prodId) {
    const prod = STATE.products.find(p => p.id === prodId);
    STATE.cart = STATE.cart.filter(item => item.productId !== prodId);
    Logger.log(`Removed "${prod.name}" from shopping cart.`, 'customer');
    updateCartStats();
};

window.moveCartItemToBasket = function(e, prodId) {
    if (e) e.stopPropagation();
    
    const prod = STATE.products.find(p => p.id === prodId);
    if (!prod) return;
    
    // Remove from cart
    STATE.cart = STATE.cart.filter(item => item.productId !== prodId);
    
    // Add to wishlist if not already present
    if (!STATE.wishlist.includes(prodId)) {
        STATE.wishlist.push(prodId);
        updateWishlistBadge();
    }
    
    Logger.log(`Moved "${prod.name}" from shopping cart to saved basket.`, 'customer');
    showToast(`Moved ${prod.name} to My Basket! 🧺`);
    
    // Trigger particle confetti on clicked element
    if (e && e.currentTarget) {
        createBasketParticles(e.currentTarget);
    }
    
    // Refresh stats & views
    updateCartStats();
    renderProducts();
    if (document.getElementById('screen-customer-wishlist').classList.contains('active')) {
        renderWishlistScreen();
    }
};

function updateCartTotals() {
    let subtotal = 0;
    STATE.cart.forEach(item => {
        const prod = STATE.products.find(p => p.id === item.productId);
        subtotal += prod.price * item.quantity;
    });

    let discount = 0;
    if (STATE.couponApplied === 'SAVE50') {
        discount = subtotal * 0.50;
    }

    const delivery = subtotal > 0 ? 3.99 : 0;
    const total = subtotal - discount + delivery;

    document.getElementById('cart-summary-subtotal').innerText = formatPrice(subtotal);
    document.getElementById('cart-summary-discount').innerText = `-${formatPrice(discount)}`;
    document.getElementById('cart-summary-delivery').innerText = formatPrice(delivery);
    document.getElementById('cart-summary-total').innerText = formatPrice(total);
}

// APPLY COUPONS
document.getElementById('btn-apply-coupon').addEventListener('click', () => {
    const code = document.getElementById('coupon-code-field').value.trim().toUpperCase();
    if (code === 'SAVE50') {
        STATE.couponApplied = 'SAVE50';
        Logger.log('Applied promotion coupon "SAVE50" (50% Off subtotal discount)!', 'customer');
        updateCartTotals();
    } else if (code === '') {
        STATE.couponApplied = null;
        updateCartTotals();
    } else {
        alert('Invalid Coupon Code! Try "SAVE50"');
        Logger.log(`Attempted invalid coupon code: "${code}"`, 'customer');
    }
});

window.selectPaymentMethod = function(method) {
    STATE.activePaymentMethod = method;
    const methods = ['gpay', 'phonepe', 'paytm', 'card', 'netbanking'];
    methods.forEach(m => {
        const el = document.getElementById(`pay-${m}`);
        if (el) {
            if (m === method) {
                el.classList.add('active');
            } else {
                el.classList.remove('active');
            }
        }
    });
    Logger.log(`Selected payment method: ${method.toUpperCase()}`, 'customer');
};

// TOGGLE CART PAYMENT METHOD SELECTOR OPTIONS
window.selectCartPaymentMethod = function(method) {
    STATE.cartSelectedPaymentMode = method;
    
    const methods = ['upi', 'card', 'netbanking'];
    methods.forEach(m => {
        const cardEl = document.getElementById(`cart-pay-${m}`);
        const formEl = document.getElementById(`cart-form-${m}`);
        
        if (cardEl && formEl) {
            if (m === method) {
                cardEl.classList.add('active');
                formEl.style.display = 'block';
            } else {
                cardEl.classList.remove('active');
                formEl.style.display = 'none';
            }
        }
    });
    Logger.log(`Selected payment method on Cart page: ${method.toUpperCase()}`, 'customer');
};

// CART UPI ID VERIFICATION
window.verifyCartUPIId = function() {
    const inputUpiId = document.getElementById('cart-input-upi-id').value.trim();
    const feedbackEl = document.getElementById('cart-upi-verify-feedback');
    const verifyBtn = document.getElementById('cart-btn-verify-upi-btn');
    
    if (inputUpiId === '') {
        alert('Please enter a valid UPI ID (e.g. name@bank)');
        return;
    }

    verifyBtn.innerText = 'Verifying...';
    verifyBtn.disabled = true;
    feedbackEl.style.display = 'none';

    setTimeout(() => {
        const regex = /^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$/;
        
        if (regex.test(inputUpiId)) {
            feedbackEl.className = 'verify-feedback success';
            feedbackEl.innerHTML = `<i class="fa-solid fa-circle-check"></i> UPI Verified (KBhavan Verified Account)`;
            feedbackEl.style.display = 'flex';
            STATE.cartUpiVerified = true;
            Logger.log(`Cart UPI ID "${inputUpiId}" verified successfully.`, 'customer');
        } else {
            feedbackEl.className = 'verify-feedback error';
            feedbackEl.innerHTML = `<i class="fa-solid fa-circle-xmark"></i> Invalid UPI ID. Format must be name@bank`;
            feedbackEl.style.display = 'flex';
            STATE.cartUpiVerified = false;
            Logger.log(`Failed verification for Cart invalid UPI format: "${inputUpiId}"`, 'customer');
        }
        verifyBtn.innerText = 'Verify';
        verifyBtn.disabled = false;
    }, 1200);
};

// CART CARD FORMATTING LISTENERS
document.getElementById('cart-input-card-number').addEventListener('input', (e) => {
    let val = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    let formattedVal = '';
    
    for (let i = 0; i < val.length; i++) {
        if (i > 0 && i % 4 === 0) formattedVal += ' ';
        formattedVal += val[i];
    }
    e.target.value = formattedVal;

    const iconContainer = document.getElementById('cart-card-brand-icon');
    if (val.startsWith('4')) {
        iconContainer.innerHTML = '<i class="fa-brands fa-cc-visa" style="color:#1A1F71;"></i>';
    } else if (val.startsWith('5')) {
        iconContainer.innerHTML = '<i class="fa-brands fa-cc-mastercard" style="color:#EB001B;"></i>';
    } else if (val.startsWith('6')) {
        iconContainer.innerHTML = '<span style="font-size: 8px; font-weight:800; color:#E28C43;">RuPay</span>';
    } else {
        iconContainer.innerHTML = '<i class="fa-solid fa-credit-card"></i>';
    }
});

document.getElementById('cart-input-card-expiry').addEventListener('input', (e) => {
    let val = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    if (val.length >= 2) {
        e.target.value = val.substring(0, 2) + '/' + val.substring(2, 4);
    } else {
        e.target.value = val;
    }
});

document.getElementById('cart-input-card-cvv').addEventListener('input', (e) => {
    e.target.value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
});

// CART PAGE CHECKOUT & SECURE TRANSACTION PROCESSOR
document.getElementById('btn-cart-checkout').addEventListener('click', () => {
    if (STATE.cart.length === 0) {
        alert('Your cart is empty! Add products first.');
        return;
    }

    // 1. Validation checks based on selected cart mode
    if (STATE.cartSelectedPaymentMode === 'upi') {
        if (!STATE.cartUpiVerified) {
            alert('Please enter and verify your UPI ID first.');
            return;
        }
    } else if (STATE.cartSelectedPaymentMode === 'card') {
        const cardNum = document.getElementById('cart-input-card-number').value.replace(/\s+/g, '');
        const cardExp = document.getElementById('cart-input-card-expiry').value.trim();
        const cardCvv = document.getElementById('cart-input-card-cvv').value.trim();
        const cardName = document.getElementById('cart-input-card-name').value.trim();
        
        if (cardNum.length < 15) {
            alert('Please enter a valid credit/debit card number.');
            return;
        }
        if (cardExp.length < 5 || !cardExp.includes('/')) {
            alert('Please enter expiration date (MM/YY).');
            return;
        }
        if (cardCvv.length < 3) {
            alert('Please enter 3-digit security CVV code.');
            return;
        }
        if (cardName === '') {
            alert('Please enter cardholder name.');
            return;
        }
    } else if (STATE.cartSelectedPaymentMode === 'netbanking') {
        const bank = document.getElementById('cart-select-netbanking-bank').value;
        if (bank === '') {
            alert('Please select your partner netbanking bank.');
            return;
        }
    }

    // 2. Start Secure Gate Simulation
    const overlay = document.getElementById('secure-processing-overlay');
    const loadingTitle = document.getElementById('secure-loading-title');
    const loadingBody = document.getElementById('secure-loading-body');
    
    overlay.style.display = 'flex';
    loadingTitle.innerText = 'Initializing Secure Gateway';
    loadingBody.innerText = 'Securing connection nodes using 256-bit encryption...';

    setTimeout(() => {
        loadingTitle.innerText = 'Contacting Banking Nodes';
        loadingBody.innerText = 'Validating payment tokens and checking fraud flags...';
    }, 850);

    setTimeout(() => {
        loadingTitle.innerText = 'Finalizing Payment Payout';
        loadingBody.innerText = 'Writing digital ledger transaction... Generating fresh harvest order...';
    }, 1700);

    setTimeout(() => {
        overlay.style.display = 'none';
        
        let subtotal = 0;
        const orderItems = STATE.cart.map(item => {
            const prod = STATE.products.find(p => p.id === item.productId);
            subtotal += prod.price * item.quantity;
            return {
                id: prod.id,
                name: prod.name,
                price: prod.price,
                quantity: item.quantity
            };
        });

        const discount = STATE.couponApplied === 'SAVE50' ? subtotal * 0.5 : 0;
        const delivery = 3.99;
        const total = subtotal - discount + delivery;
        const otp = Math.floor(1000 + Math.random() * 9000).toString();
        const orderId = `ORD-${Math.floor(100000 + Math.random() * 900000)}`;

        const newOrder = {
            id: orderId,
            items: orderItems,
            subtotal: subtotal,
            discount: discount,
            delivery: delivery,
            total: total,
            otp: otp,
            status: 'placed',
            paymentMethod: STATE.cartSelectedPaymentMode,
            timestamp: new Date().toLocaleTimeString()
        };

        STATE.orders.push(newOrder);
        
        // Clear Cart & reset cart fields
        STATE.cart = [];
        STATE.couponApplied = null;
        document.getElementById('coupon-code-field').value = '';
        
        // Clear Cart Payment Fields
        document.getElementById('cart-input-upi-id').value = '';
        document.getElementById('cart-upi-verify-feedback').style.display = 'none';
        document.getElementById('cart-input-card-number').value = '';
        document.getElementById('cart-input-card-expiry').value = '';
        document.getElementById('cart-input-card-cvv').value = '';
        document.getElementById('cart-input-card-name').value = '';
        document.getElementById('cart-select-netbanking-bank').value = '';
        STATE.cartUpiVerified = false;
        selectCartPaymentMethod('upi');
        
        updateCartStats();

        Logger.log(`Successfully completed order ${orderId} (Paid via ${STATE.cartSelectedPaymentMode.toUpperCase()}) for a total of ${formatPrice(total)}`, 'customer');
        
        // Reset payment selection back to default for next checkout
        STATE.activePaymentMethod = 'gpay';
        const methods = ['gpay', 'phonepe', 'paytm', 'card', 'netbanking'];
        methods.forEach(m => {
            const el = document.getElementById(`pay-${m}`);
            if (el) {
                if (m === 'gpay') el.classList.add('active');
                else el.classList.remove('active');
            }
        });
        
        // Prepare Tracking Screen
        document.getElementById('tracking-order-id').innerText = `#${orderId}`;
        document.getElementById('tracking-delivery-otp').innerText = otp;
        updateTrackingTimeline(newOrder);
        
        // Swap screen to tracking
        switchScreen('screen-customer-tracking');
        
        // Notify Farmer
        const activeFarmer = STATE.merchants[0]; // Organico Farm
        activeFarmer.activeOrders += 1;
        updateFarmerStats();
        
        Logger.log(`New incoming order alert sent to ${activeFarmer.name}`, 'system');
        Notification.show('Order Placed!', `Farm alert: Organico Farm has received order ${orderId}.`);
        showToast('Payment Approved! 🛡️');
    }, 2500);
});

// ORDER STATUS TRACKING TIMELINE
function updateTrackingTimeline(order) {
    const steps = ['placed', 'accepted', 'prepared', 'transit', 'completed'];
    const currentIdx = steps.indexOf(order.status);
    
    steps.forEach((step, idx) => {
        const el = document.getElementById(`step-${step}`);
        if (!el) return;
        
        el.className = 'timeline-item';
        if (idx < currentIdx) {
            el.classList.add('completed');
        } else if (idx === currentIdx) {
            el.classList.add('active');
        }
    });
}

function syncTrackingUI() {
    const trackingOrderIdEl = document.getElementById('tracking-order-id');
    if (!trackingOrderIdEl) return;
    const orderId = trackingOrderIdEl.innerText.replace('#', '').trim();
    if (!orderId) return;
    const order = STATE.orders.find(o => o.id === orderId);
    if (order) {
        updateTrackingTimeline(order);
    }
}

// FARMER CONSOLE LOGIC
function updateFarmerStats() {
    const farmer = STATE.merchants[0];
    document.getElementById('farmer-total-earnings').innerText = formatPrice(farmer.earnings);
    document.getElementById('farmer-active-orders').innerText = farmer.activeOrders;
}

function renderFarmerOrders() {
    const container = document.getElementById('farmer-orders-list');
    const pending = STATE.orders.filter(o => o.status === 'placed' || o.status === 'accepted');
    
    if (pending.length === 0) {
        container.innerHTML = '<div style="font-size:11px; text-align:center; padding: 20px; color:var(--text-muted);">No active pending orders.</div>';
        return;
    }

    container.innerHTML = pending.map(o => {
        const itemsSummary = o.items.map(i => `${i.quantity}x ${i.name}`).join(', ');
        
        let actionBtn = '';
        if (o.status === 'placed') {
            actionBtn = `<button class="btn-action-small" onclick="farmerAcceptOrder('${o.id}')">Accept Order</button>`;
        } else if (o.status === 'accepted') {
            actionBtn = `<button class="btn-action-small" style="background:var(--primary-gradient); color:white;" onclick="farmerPrepareOrder('${o.id}')">Mark Prepared</button>`;
        }

        return `
            <div class="order-card-merchant">
                <div class="order-card-header">
                    <span style="font-weight:700;">#${o.id}</span>
                    <span style="color:var(--primary);text-transform:uppercase;font-size:9px;">${o.status}</span>
                </div>
                <div class="order-card-items-list">${itemsSummary}</div>
                <div class="order-card-footer">
                    <span class="order-card-price">${formatPrice(o.total)}</span>
                    ${actionBtn}
                </div>
            </div>
        `;
    }).join('');
}

function renderFarmerInventory() {
    const container = document.getElementById('farmer-inventory-list');
    if (!container) return;
    container.innerHTML = STATE.products.map(p => {
        let priceStr = typeof p.price === 'number' ? `$${p.price.toFixed(2)}` : p.price;
        return `
            <div class="order-card-merchant" style="margin-bottom:8px; display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <div style="font-weight:700; font-size:12px;">${p.name}</div>
                    <div style="font-size:10px; color:var(--text-muted);">${p.weight} | ${priceStr}</div>
                </div>
                <button class="btn-action-small" style="background:#fee2e2; color:#ef4444; border:none; padding:4px 8px;" onclick="farmerDeleteProduct('${p.id}')">Delete</button>
            </div>
        `;
    }).join('');
}

window.farmerDeleteProduct = function(pId) {
    STATE.products = STATE.products.filter(p => p.id !== pId);
    renderFarmerInventory();
    renderProducts();
    Logger.log(`Farmer deleted product ID: ${pId} from online market.`, 'farmer');
};


window.farmerAcceptOrder = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'accepted';
    Logger.log(`Farmer accepted order #${orderId}. Preparing products for packaging...`, 'farmer');
    renderFarmerOrders();
    
    // Simulate push alert to customer
    Notification.show('Order Preparing', `Farmer accepted your order #${orderId}. Fresh produce is being gathered!`);
    syncTrackingUI();
};

window.farmerPrepareOrder = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'prepared';
    Logger.log(`Farmer finished packaging order #${orderId}. Dispatched to delivery rider pool!`, 'farmer');
    
    const farmer = STATE.merchants[0];
    if (farmer.activeOrders > 0) farmer.activeOrders -= 1;
    updateFarmerStats();
    renderFarmerOrders();
    
    // Trigger notification to Rider & Customer
    Notification.show('Harvest Ready!', `Order #${orderId} is prepared and waiting for pickup.`);
    syncTrackingUI();
};

// RIDER CONSOLE LOGIC
function renderRiderDashboard() {
    // Stats
    document.getElementById('delivery-earnings').innerText = formatPrice(STATE.rider.earnings);
    document.getElementById('delivery-trips').innerText = STATE.rider.trips;
    
    const jobBoardSection = document.getElementById('delivery-job-board-section');
    const activeJobSection = document.getElementById('delivery-active-job-section');
    
    if (STATE.rider.activeOrderId) {
        jobBoardSection.style.display = 'none';
        activeJobSection.style.display = 'block';
        
        // Setup driving navigation simulation
        const order = STATE.orders.find(o => o.id === STATE.rider.activeOrderId);
        document.getElementById('delivery-info-text').innerText = `Transit to Client (OTP: ${order.otp})`;
        
        // Start animation driving
        const map = document.getElementById('rider-map');
        map.classList.add('driving');
    } else {
        jobBoardSection.style.display = 'block';
        activeJobSection.style.display = 'none';
        
        // Reset Map driving animation
        const map = document.getElementById('rider-map');
        map.classList.remove('driving');
        
        renderRiderJobs();
    }
}

function renderRiderJobs() {
    const container = document.getElementById('delivery-jobs-list');
    const jobs = STATE.orders.filter(o => o.status === 'prepared');
    
    if (jobs.length === 0) {
        container.innerHTML = '<div style="font-size:11px; text-align:center; padding: 20px; color:var(--text-muted);">No packages currently waiting for dispatch.</div>';
        return;
    }

    container.innerHTML = jobs.map(o => {
        const itemsSummary = o.items.map(i => `${i.quantity}x ${i.name}`).join(', ');
        return `
            <div class="order-card-merchant">
                <div class="order-card-header">
                    <span style="font-weight:700;">#${o.id}</span>
                    <span style="color:#2E7D32;">Prepared</span>
                </div>
                <div class="order-card-items-list">${itemsSummary}</div>
                <div class="order-card-footer">
                    <span class="order-card-price">${formatPrice(o.total)}</span>
                    <button class="btn-action-small" style="background:#E28C43; color:white;" onclick="riderAcceptJob('${o.id}')">Accept Delivery</button>
                </div>
            </div>
        `;
    }).join('');
}

window.riderAcceptJob = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'transit';
    STATE.rider.activeOrderId = orderId;
    
    Logger.log(`Rider Alex Rider accepted delivery trip for order #${orderId}. Navigating to client address...`, 'delivery');
    renderRiderDashboard();
    
    // Simulate push alert to customer
    Notification.show('Rider Out for Delivery!', `Rider Alex is on his way with your FarmFresh vegetables.`);
    syncTrackingUI();
};

// CONFIRM DELIVERY WITH OTP
document.getElementById('btn-delivery-submit-otp').addEventListener('click', () => {
    const inputOtp = document.getElementById('delivery-otp-confirm-input').value.trim();
    const orderId = STATE.rider.activeOrderId;
    
    if (!orderId) return;
    
    const order = STATE.orders.find(o => o.id === orderId);
    
    if (inputOtp === order.otp) {
        // Complete Order
        order.status = 'completed';
        STATE.rider.activeOrderId = null;
        
        // Payout allocations
        const deliveryFee = 3.99;
        const farmerEarnings = order.total - deliveryFee;
        const riderPayout = 5.00; // Flat delivery agent payout
        
        // Credit Farmer
        const farmer = STATE.merchants[0];
        farmer.earnings += farmerEarnings;
        
        // Credit Rider
        STATE.rider.earnings += riderPayout;
        STATE.rider.trips += 1;
        
        // Credit Admin Log
        STATE.admin.totalSales += order.total;
        STATE.admin.totalOrders += 1;
        
        document.getElementById('delivery-otp-confirm-input').value = '';
        
        Logger.log(`Rider verified OTP correctly. Delivery completed! Payout of ${formatPrice(riderPayout)} credited to Rider. Farmer credited ${formatPrice(farmerEarnings)}`, 'delivery');
        
        renderRiderDashboard();
        
        // Alert Customer
        Notification.show('Order Delivered!', `Your delivery for order #${orderId} is complete. Bon Appétit!`);
        syncTrackingUI();
    } else {
        alert('Invalid OTP Code! Check customer tracking screen for correct pin.');
        Logger.log(`Rider entered wrong OTP: "${inputOtp}" for order #${orderId}`, 'delivery');
    }
});

// FARMER ADD NEW HARVEST ITEM
document.getElementById('btn-farmer-add-product').addEventListener('click', () => {
    const name = document.getElementById('form-new-pname').value.trim();
    const priceInput = parseFloat(document.getElementById('form-new-price').value);
    const weight = document.getElementById('form-new-unit').value.trim();
    const category = document.getElementById('form-new-category').value;
    
    if (!name || isNaN(priceInput) || !weight) {
        alert('Please fill out all product details correctly!');
        return;
    }
    
    // Store price internally in base USD
    const price = priceInput / currentCurrencyRate;
    
    // Pick dynamic food emojis based on categories
    let emoji = '🍏';
    if (category === 'vegetables') emoji = '🥦';
    else if (category === 'meat') emoji = '🥩';
    else if (category === 'dairy') emoji = '🧀';
    
    const newProd = {
        id: `prod-${STATE.products.length + 1}`,
        name: name,
        price: price,
        originalPrice: price,
        discount: null,
        origin: 'Organico Farm, US',
        category: category,
        image: emoji,
        description: `Freshly harvested organic ${name} grown by local farmers at Organico Farm. Packed carefully for delivery.`,
        calories: '120 kcal',
        protein: '3 gram',
        fat: '0 gram',
        weight: weight
    };
    
    STATE.products.unshift(newProd);
    
    // Clear forms
    document.getElementById('form-new-pname').value = '';
    document.getElementById('form-new-price').value = '';
    document.getElementById('form-new-unit').value = '';
    
    Logger.log(`Farmer published new product harvest: "${name}" ($${price.toFixed(2)} per ${weight}) to storefront.`, 'farmer');
    
    // Rerender grids
    renderProducts();
    renderFarmerInventory();
    Notification.show('New Harvest Item!', `Merchant published ${name} to the online market.`);
});

// ADMIN PANEL DASHBOARD
function renderAdminDashboard() {
    document.getElementById('admin-total-sales').innerText = formatPrice(STATE.admin.totalSales);
    document.getElementById('admin-total-orders').innerText = STATE.admin.totalOrders;
    
    const container = document.getElementById('admin-merchant-verification-list');
    const pendingMerchants = STATE.merchants.filter(m => !m.verified);
    
    if (pendingMerchants.length === 0) {
        container.innerHTML = '<div style="font-size:11px; text-align:center; padding: 15px; color:var(--text-muted);">No merchants currently in verification queue.</div>';
        return;
    }
    
    container.innerHTML = pendingMerchants.map(m => `
        <div class="order-card-merchant" style="margin-bottom:8px;">
            <div style="font-size:12px; font-weight:700; color:var(--text-main);">${m.name}</div>
            <div style="font-size:10px; color:var(--text-muted); margin-bottom:6px;">Applicant Role: Farmer Store</div>
            <button class="btn-action-small" onclick="adminVerifyMerchant('${m.id}')">Approve & Verify Account</button>
        </div>
    `).join('');
}

window.adminVerifyMerchant = function(mId) {
    const merchant = STATE.merchants.find(m => m.id === mId);
    if (!merchant) return;
    
    merchant.verified = true;
    Logger.log(`Administrator verified and approved merchant account: "${merchant.name}"`, 'admin');
    renderAdminDashboard();
    
    Notification.show('Farmer Account Verified!', `${merchant.name} has been approved to sell products.`);
};

// SEARCH STOREFRONT
document.getElementById('product-search-input').addEventListener('input', (e) => {
    STATE.searchQuery = e.target.value;
    renderProducts();
});

// ONBOARDING WORKFLOW TRIGGER
document.getElementById('btn-onboard-start').addEventListener('click', () => {
    Logger.log('Customer began store session.', 'customer');
    switchScreen('screen-customer-home');
});

// BACK NAVIGATION TRIGGERS
document.getElementById('btn-onboard-back').addEventListener('click', () => {
    Logger.log('Onboarding exit attempted. Sandbox loop resumed.', 'system');
});
document.getElementById('btn-details-back').addEventListener('click', () => {
    switchScreen('screen-customer-home');
});
document.getElementById('btn-details-add-to-cart').addEventListener('click', () => {
    if (STATE.selectedProductId) {
        addToCart(null, STATE.selectedProductId);
    }
});
const btnPaymentBack = document.getElementById('btn-payment-back');
if (btnPaymentBack) {
    btnPaymentBack.addEventListener('click', () => {
        switchScreen('screen-customer-cart');
    });
}
document.getElementById('btn-tracking-cancel').addEventListener('click', () => {
    switchScreen('screen-customer-home', 'tab-home');
});

// ROLE SELECT WORKSPACE SYNC
document.getElementById('btn-role-customer').addEventListener('click', () => switchRole('customer'));
document.getElementById('btn-role-farmer').addEventListener('click', () => switchRole('farmer'));
document.getElementById('btn-role-delivery').addEventListener('click', () => switchRole('delivery'));

// CATEGORIES SCREEN RENDER & NAVIGATION FLOW
window.renderCategoriesScreen = function() {
    const grid = document.getElementById('categories-large-grid');
    if (!grid) return;
    
    const query = (STATE.categoriesSearchQuery || '').toLowerCase();
    
    const categoriesData = [
        { id: 'fruits', label: 'Fresh Fruits', icon: '🍎', color: '#FAD2E1', text: '#C9184A', desc: 'Organic orchard harvests' },
        { id: 'vegetables', label: 'Vegetables', icon: '🥕', color: '#EAF6EC', text: '#2E7D32', desc: 'Fresh farm green veggies' },
        { id: 'meat', label: 'Premium Meat', icon: '🥩', color: '#FFE5D9', text: '#D04A02', desc: 'Grass-fed cuts & poultry' },
        { id: 'dairy', label: 'Dairy & Eggs', icon: '🥛', color: '#FFF1E6', text: '#E28C43', desc: 'Butter, cheese & farm eggs' }
    ];
    
    const filtered = categoriesData.filter(c => c.label.toLowerCase().includes(query) || c.desc.toLowerCase().includes(query));
    
    if (filtered.length === 0) {
        grid.innerHTML = '<div style="grid-column: span 2; text-align:center; padding: 30px; color:var(--text-muted); font-size:12px;">No matching categories.</div>';
        return;
    }
    
    grid.innerHTML = filtered.map(c => {
        const count = STATE.products.filter(p => p.category === c.id).length;
        
        return `
            <div class="category-large-card" onclick="selectCategoryFromScreen('${c.id}')" style="background: ${c.color}33; border: 1px solid ${c.color}; border-radius: 20px; padding: 16px; display:flex; flex-direction:column; gap:12px; cursor:pointer;">
                <div style="font-size: 32px;">${c.icon}</div>
                <div>
                    <h3 style="font-size: 13px; font-weight: 800; color: ${c.text};">${c.label}</h3>
                    <p style="font-size: 9px; color: var(--text-muted); margin-top: 2px;">${c.desc}</p>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-top:4px;">
                    <span style="font-size: 9px; font-weight: 700; color: ${c.text}; background: ${c.color}66; padding: 2px 8px; border-radius: 8px;">${count} items</span>
                    <i class="fa-solid fa-circle-arrow-right" style="color: ${c.text}; font-size:16px;"></i>
                </div>
            </div>
        `;
    }).join('');
};

window.filterCategoriesScreen = function(val) {
    STATE.categoriesSearchQuery = val;
    renderCategoriesScreen();
};

window.selectCategoryFromScreen = function(catId) {
    STATE.activeCategory = catId;
    renderCategories();
    renderProducts();
    switchScreen('screen-customer-home', 'tab-home');
    Logger.log(`Selected category "${catId}" from category browser screen.`, 'customer');
};

// TAB NAV BAR LISTENERS
document.getElementById('tab-home').addEventListener('click', () => switchScreen('screen-customer-home', 'tab-home'));
document.getElementById('tab-categories').addEventListener('click', () => {
    switchScreen('screen-customer-categories', 'tab-categories');
    renderCategoriesScreen();
});
document.getElementById('tab-cart').addEventListener('click', () => {
    switchScreen('screen-customer-cart', 'tab-cart');
    renderCart();
});
document.getElementById('tab-tracking').addEventListener('click', () => {
    // Show tracking for latest order, or default placeholder
    if (STATE.orders.length > 0) {
        const latest = STATE.orders[STATE.orders.length - 1];
        document.getElementById('tracking-order-id').innerText = `#${latest.id}`;
        document.getElementById('tracking-delivery-otp').innerText = latest.otp;
        updateTrackingTimeline(latest);
    }
    switchScreen('screen-customer-tracking', 'tab-tracking');
});

// FARMER TAB LISTENERS
document.getElementById('tab-farmer-dashboard').addEventListener('click', () => {
    switchScreen('screen-farmer-dashboard');
    renderFarmerOrders();
    updateFarmerStats();
});
document.getElementById('tab-farmer-products').addEventListener('click', () => {
    switchScreen('screen-farmer-products');
    renderFarmerInventory();
});
document.getElementById('tab-farmer-profile').addEventListener('click', () => {
    switchScreen('screen-farmer-profile');
});

// DELIVERY TAB LISTENERS
document.getElementById('tab-delivery-dashboard').addEventListener('click', () => {
    switchScreen('screen-delivery-dashboard');
    renderRiderDashboard();
});
document.getElementById('tab-delivery-profile').addEventListener('click', () => {
    switchScreen('screen-delivery-profile');
});


// CLEAR LEDGER LOGS
document.getElementById('btn-clear-logs').addEventListener('click', () => Logger.clear());

// Location Picker Currency updates
document.getElementById('user-location-selector').addEventListener('change', (e) => {
    const val = e.target.value;
    if (val === 'Mumbai, India') {
        currentCurrencySymbol = 'Rs. ';
        currentCurrencyRate = 83.0; // Exchange rate: 1 USD = 83 INR
        Logger.log('Location switched to India. Currency updated to Rupees (Rs.)', 'customer');
    } else {
        currentCurrencySymbol = '$';
        currentCurrencyRate = 1.0;
        Logger.log(`Location switched to ${val}. Currency updated to US Dollars ($)`, 'customer');
    }
    
    // Re-render all components to reflect new currency symbols
    renderProducts();
    updateCartStats();
    renderFarmerOrders();
    updateFarmerStats();
    renderRiderDashboard();
    renderAdminDashboard();
});

// PROFILE DROP-DOWN & DROPDOWN EVENTS
window.toggleProfileDropdown = function(e) {
    if (e) e.stopPropagation();
    const dropdown = document.getElementById('profile-more-dropdown');
    if (dropdown) {
        const isVisible = dropdown.style.display === 'block';
        dropdown.style.display = isVisible ? 'none' : 'block';
    }
};

window.editProfileOption = function() {
    const currentEmail = STATE.userEmail || "ritih@gmail.com";
    const newEmail = prompt("Enter new profile email address:", currentEmail);
    if (newEmail !== null && newEmail.trim() !== "") {
        STATE.userEmail = newEmail.trim();
        showToast('Profile email updated! ✏️');
        Logger.log(`Customer updated profile email to: ${STATE.userEmail}`, 'customer');
    }
};

window.logoutUserOption = function() {
    showToast('Logged out successfully! 👋');
    Logger.log('Customer logged out. Redirected to onboarding screen.', 'system');
    switchScreen('screen-onboarding');
};

// ACCOUNT MODAL CONTROL PANEL SYSTEM
window.openAccountModal = function(title, contentHTML) {
    const modal = document.getElementById('account-detail-modal');
    const titleEl = document.getElementById('account-modal-title');
    const bodyEl = document.getElementById('account-modal-body');
    
    if (modal && titleEl && bodyEl) {
        titleEl.innerText = title;
        bodyEl.innerHTML = contentHTML;
        modal.style.display = 'flex';
        // Trigger reflow for transition
        modal.offsetHeight;
        modal.classList.add('active');
        Logger.log(`Opened account details panel: "${title}"`, 'customer');
    }
};

window.closeAccountModal = function() {
    const modal = document.getElementById('account-detail-modal');
    if (modal) {
        modal.classList.remove('active');
        setTimeout(() => {
            if (!modal.classList.contains('active')) {
                modal.style.display = 'none';
            }
        }, 250);
    }
};

window.copyPromo = function(code) {
    navigator.clipboard.writeText(code).then(() => {
        showToast(`Promo "${code}" copied! 📋`);
        Logger.log(`Customer copied voucher code: "${code}"`, 'customer');
    }).catch(() => {
        showToast(`Voucher code: ${code} active!`);
    });
};

window.triggerActualDownload = function() {
    const selected = document.querySelector('input[name="statement_period"]:checked');
    const period = selected ? selected.value : 'June 2026';
    showToast(`Downloading statement for ${period}... 📥`);
    Logger.log(`Customer exported transaction statement PDF for period: ${period}`, 'customer');
    closeAccountModal();
};

window.openProfileAddresses = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="border:1px solid var(--green-light); background:#F9FBF9; border-radius:12px; padding:12px; position:relative;">
                <span style="font-weight:700; color:var(--green-dark); display:block; font-size:11px;">Home (Default) 🏠</span>
                <span style="color:#555; display:block; margin-top:2px; font-size:10px;">Santorini Heights, Block C-12, Sector 5</span>
                <span style="color:#888; font-size:9px; display:block; margin-top:4px;">Rider Instructions: Ring bell, leave on doorstep.</span>
            </div>
            <div style="border:1px solid #ECECEC; border-radius:12px; padding:12px; opacity:0.8;">
                <span style="font-weight:700; color:var(--text-main); display:block; font-size:11px;">Office 💼</span>
                <span style="color:#555; display:block; margin-top:2px; font-size:10px;">Tech Hub Plaza, Tower B, 4th Floor</span>
            </div>
            <button onclick="showToast('Address builder coming soon! 🏗️')" class="btn-primary-gradient" style="height:38px; border-radius:12px; font-size:11px; margin-top:8px;">Add New Address</button>
        </div>
    `;
    openAccountModal('Saved Addresses', html);
};

window.openProfilePayments = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="display:flex; align-items:center; justify-content:space-between; border:1px solid #ECECEC; border-radius:12px; padding:12px;">
                <div style="display:flex; align-items:center; gap:10px;">
                    <i class="fa-solid fa-building-columns" style="font-size:16px; color:#555; width:20px; text-align:center;"></i>
                    <div>
                        <span style="font-weight:700; color:var(--text-main); display:block;">HDFC Bank UPI</span>
                        <span style="color:#888; font-size:9px;">ritih@hdfcbank</span>
                    </div>
                </div>
                <span style="font-size:9px; font-weight:700; color:var(--green-dark); background:var(--green-light); padding:2px 6px; border-radius:6px;">Active</span>
            </div>
            <div style="display:flex; align-items:center; justify-content:space-between; border:1px solid #ECECEC; border-radius:12px; padding:12px;">
                <div style="display:flex; align-items:center; gap:10px;">
                    <i class="fa-solid fa-credit-card" style="font-size:16px; color:#555; width:20px; text-align:center;"></i>
                    <div>
                        <span style="font-weight:700; color:var(--text-main); display:block;">Visa Credit Card</span>
                        <span style="color:#888; font-size:9px;">**** **** **** 9012</span>
                    </div>
                </div>
            </div>
        </div>
    `;
    openAccountModal('Payment Methods', html);
};

window.openProfileRefunds = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="border:1px solid #ECECEC; border-radius:12px; padding:12px;">
                <div style="display:flex; justify-content:space-between; font-weight:700; color:var(--text-main);">
                    <span>Refund #REF-9021</span>
                    <span style="color:var(--green-dark); font-size:10px; font-weight:800;">SUCCESS</span>
                </div>
                <div style="color:#888; font-size:9px; margin-top:2px;">July 08, 2026 • Rs. 145.00</div>
                <p style="color:#555; margin-top:6px; font-size:10px; line-height:1.35;">Refunded back to origin UPI for order #ORD-1001 (Out of stock: Organic Blueberries).</p>
            </div>
            <div style="text-align:center; padding:12px; color:var(--text-muted);">
                <i class="fa-solid fa-circle-check" style="font-size:24px; color:var(--green-dark); margin-bottom:6px; display:block;"></i>
                No other pending refunds!
            </div>
        </div>
    `;
    openAccountModal('My Refunds', html);
};

window.openProfileWallet = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:12px;">
            <div style="background:var(--primary-gradient); color:#fff; border-radius:16px; padding:16px; text-align:center;">
                <span style="font-size:10px; opacity:0.9; text-transform:uppercase; letter-spacing:0.5px;">Wallet Balance</span>
                <h2 style="font-family:var(--font-heading); font-size:24px; margin-top:4px; font-weight:800;">Rs. 420.00</h2>
                <span style="font-size:9px; opacity:0.8;">Equivalent to $5.00</span>
            </div>
            <div>
                <span style="font-weight:700; display:block; margin-bottom:6px; font-size:11px;">Recent Wallet Transactions</span>
                <div style="display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid #F5F5F5;">
                    <div>
                        <span style="font-weight:700; color:var(--text-main); display:block;">Cashback Reward</span>
                        <span style="color:#888; font-size:9px;">July 09, 2026</span>
                    </div>
                    <span style="font-weight:700; color:var(--green-dark);">+Rs. 20.00</span>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; padding:8px 0;">
                    <div>
                        <span style="font-weight:700; color:var(--text-main); display:block;">Refund Credit</span>
                        <span style="color:#888; font-size:9px;">July 08, 2026</span>
                    </div>
                    <span style="font-weight:700; color:var(--green-dark);">+Rs. 400.00</span>
                </div>
            </div>
            <button onclick="showToast('Top up is disabled in demo mode 💳')" class="btn-primary-gradient" style="height:36px; border-radius:12px; font-size:11px;">Top Up Wallet</button>
        </div>
    `;
    openAccountModal('Farm Fresh Money Wallet', html);
};

window.openProfileCreditCard = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:12px;">
            <div style="background:linear-gradient(135deg, #1D2D44 0%, #0F1A24 100%); color:#fff; border-radius:16px; padding:18px; position:relative; box-shadow:0 8px 20px rgba(0,0,0,0.15);">
                <span style="font-family:var(--font-heading); font-size:12px; font-weight:800; letter-spacing:0.5px;">FARM FRESH</span>
                <div style="font-size:14px; font-weight:700; margin-top:20px; letter-spacing:1px;">HDFC Bank Co-brand</div>
                <div style="margin-top:25px; display:flex; justify-content:space-between; align-items:center;">
                    <span style="font-size:10px; opacity:0.8;">VISA PLATINUM</span>
                    <i class="fa-solid fa-wifi" style="font-size:12px;"></i>
                </div>
            </div>
            <div>
                <span style="font-weight:700; display:block; margin-bottom:6px; font-size:11px;">Exclusive Card Perks</span>
                <ul style="padding-left:16px; display:flex; flex-direction:column; gap:4px; color:#555; font-size:10px;">
                    <li><strong>5% Cashback</strong> on all organic farm purchases.</li>
                    <li>Free delivery on orders above Rs. 199.</li>
                    <li>10% off at partnered local nurseries.</li>
                </ul>
            </div>
        </div>
    `;
    openAccountModal('Credit Card Rewards', html);
};

window.openProfileVouchers = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="border:2px dashed var(--green-dark); background:#F7FCF8; border-radius:14px; padding:12px; display:flex; align-items:center; justify-content:space-between;">
                <div>
                    <span style="font-family:var(--font-heading); font-size:13px; font-weight:800; color:var(--green-dark); display:block;">SAVE50</span>
                    <span style="color:#555; font-size:9px; display:block; margin-top:2px;">50% discount on your first order!</span>
                </div>
                <button onclick="copyPromo('SAVE50')" style="background:var(--green-dark); color:#fff; border:none; border-radius:8px; padding:4px 10px; font-size:9px; font-weight:700; cursor:pointer;">Copy</button>
            </div>
            <div style="border:2px dashed #ECECEC; border-radius:14px; padding:12px; display:flex; align-items:center; justify-content:space-between; opacity:0.6;">
                <div>
                    <span style="font-family:var(--font-heading); font-size:13px; font-weight:800; color:#888; display:block;">FRESHFREE</span>
                    <span style="color:#888; font-size:9px; display:block; margin-top:2px;">Free delivery coupon.</span>
                </div>
                <button disabled style="background:#CCC; color:#FFF; border:none; border-radius:8px; padding:4px 10px; font-size:9px; font-weight:700;">Claimed</button>
            </div>
        </div>
    `;
    openAccountModal('My Vouchers', html);
};

window.downloadProfileStatements = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <span style="font-weight:700; font-size:11px; display:block;">Select Statement Period</span>
            <div style="display:flex; flex-direction:column; gap:6px;">
                <label style="display:flex; align-items:center; gap:8px; border:1px solid #ECECEC; border-radius:8px; padding:10px; cursor:pointer; font-size:10px;">
                    <input type="radio" name="statement_period" checked value="June 2026">
                    <span>June 2026 Statement (Current)</span>
                </label>
                <label style="display:flex; align-items:center; gap:8px; border:1px solid #ECECEC; border-radius:8px; padding:10px; cursor:pointer; font-size:10px;">
                    <input type="radio" name="statement_period" value="May 2026">
                    <span>May 2026 Statement</span>
                </label>
            </div>
            <button onclick="triggerActualDownload()" class="btn-primary-gradient" style="height:36px; border-radius:12px; font-size:11px; margin-top:6px;">Download PDF</button>
        </div>
    `;
    openAccountModal('Account Statements', html);
};

window.openCorporateRewards = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="text-align:center; padding:10px 0;">
                <i class="fa-solid fa-briefcase" style="font-size:36px; color:var(--primary); margin-bottom:8px; display:block;"></i>
                <h4 style="font-size:12px; font-weight:800; color:var(--text-main);">Google Corporate Program</h4>
                <p style="color:var(--text-muted); font-size:9px; margin-top:2px;">Authorized via company email domain.</p>
            </div>
            <div style="border-top:1px solid #F0F0F0; padding-top:12px; display:flex; flex-direction:column; gap:8px; font-size:10px;">
                <div style="display:flex; justify-content:space-between;">
                    <span>Status:</span>
                    <strong style="color:var(--green-dark);">ACTIVE</strong>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span>Discount Tier:</span>
                    <strong>12% Flat Off Storewide</strong>
                </div>
            </div>
        </div>
    `;
    openAccountModal('Corporate Rewards', html);
};

window.openStudentRewards = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="text-align:center; padding:10px 0;">
                <i class="fa-solid fa-graduation-cap" style="font-size:36px; color:#4A90E2; margin-bottom:8px; display:block;"></i>
                <h4 style="font-size:12px; font-weight:800; color:var(--text-main);">Student Discount Club</h4>
                <p style="color:var(--text-muted); font-size:9px; margin-top:2px;">Verified via Student ID Portal</p>
            </div>
            <div style="border:1px solid #EAEAEA; border-radius:12px; padding:12px; text-align:center;">
                <span style="font-size:10px; color:#555; display:block;">Student verification active for school year.</span>
                <span style="font-size:14px; font-weight:800; color:#4A90E2; display:block; margin-top:4px;">15% OFF FARM PRODUCTS</span>
            </div>
        </div>
    `;
    openAccountModal('Student Rewards', html);
};

window.openPartnerRewards = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px;">
            <div style="display:flex; align-items:center; gap:12px; border:1px solid #ECECEC; border-radius:12px; padding:12px;">
                <i class="fa-solid fa-mug-hot" style="font-size:24px; color:#006241; width:24px; text-align:center;"></i>
                <div>
                    <span style="font-weight:700; color:var(--text-main); display:block; font-size:11px;">Starbucks Coffee</span>
                    <span style="color:#555; font-size:9px; display:block; margin-top:2px;">Claim a free Espresso brew on orders above Rs. 499.</span>
                </div>
            </div>
            <div style="display:flex; align-items:center; gap:12px; border:1px solid #ECECEC; border-radius:12px; padding:12px;">
                <i class="fa-solid fa-dumbbell" style="font-size:20px; color:#4A4A4A; width:24px; text-align:center;"></i>
                <div>
                    <span style="font-weight:700; color:var(--text-main); display:block; font-size:11px;">FitPass Premium</span>
                    <span style="color:#555; font-size:9px; display:block; margin-top:2px;">Get a 7-day gym trial pass with any fruit basket.</span>
                </div>
            </div>
        </div>
    `;
    openAccountModal('Partner Program Deals', html);
};

window.updateDefaultLoginEmail = function(role) {
    const emailField = document.getElementById('login-email');
    if (role === 'farmer') {
        emailField.value = 'farmer@farmfresh.com';
    } else if (role === 'delivery') {
        emailField.value = 'delivery@farmfresh.com';
    } else {
        emailField.value = 'customer@farmfresh.com';
    }
};

window.submitSimulatorLogin = function() {
    const role = document.getElementById('login-role').value;
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;

    if (!email || !password) {
        showToast('Please enter credentials');
        return;
    }

    showToast(`Logged in successfully as ${role}!`);
    Logger.log(`Authenticated via database matching role: ${role.toUpperCase()}`, 'system');

    // Switch view automatically based on the selected role
    switchRole(role);
};

window.toggleContactPermission = function(el) {
    const stateEl = document.getElementById('profile-contact-state');
    if (stateEl) {
        const isYes = stateEl.innerText === 'YES';
        stateEl.innerText = isYes ? 'NO' : 'YES';
        stateEl.style.color = isYes ? '#E63946' : 'var(--green-dark)';
        showToast(isYes ? 'Farmer calls muted. 📴' : 'Allowed farmers to contact you! 📞');
        Logger.log(`Customer updated merchant contact permission to: ${isYes ? 'MUTED' : 'ALLOWED'}.`, 'customer');
    }
};

window.addEventListener('click', () => {
    const dropdown = document.getElementById('profile-more-dropdown');
    if (dropdown) {
        dropdown.style.display = 'none';
    }
});

// INITIAL SETUP RUNS
renderCategories();
renderProducts();
Logger.log('Interactive Multi-Vendor FarmFresh Simulator re-initialized.', 'system');
Logger.log('Ready to test. Switch roles above to inspect screens.', 'system');
