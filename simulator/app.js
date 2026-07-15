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

// LocalStorage Persistence Layer
(function restoreStateFromStorage() {
    try {
        const saved = localStorage.getItem('FARMFRESH_STATE');
        if (saved) {
            const parsed = JSON.parse(saved);
            
            // Restore products: merge saved farmer products with default ones
            if (parsed.products) {
                const defaultIds = STATE.products.map(p => p.id);
                const farmerProds = parsed.products.filter(p => p.addedByFarmer && !defaultIds.includes(p.id));
                STATE.products.push(...farmerProds);
                
                // Sync properties for default products if changed
                parsed.products.forEach(p => {
                    if (!p.addedByFarmer) {
                        const target = STATE.products.find(tp => tp.id === p.id);
                        if (target) {
                            Object.assign(target, p);
                        }
                    }
                });
            }
            
            if (parsed.cart) STATE.cart = parsed.cart;
            if (parsed.wishlist) STATE.wishlist = parsed.wishlist;
            if (parsed.orders) STATE.orders = parsed.orders;
            if (parsed.addresses) STATE.addresses = parsed.addresses;
            if (parsed.couponApplied) STATE.couponApplied = parsed.couponApplied;
            if (parsed.currentRole) STATE.currentRole = parsed.currentRole;
            if (parsed.customerLocation) STATE.customerLocation = parsed.customerLocation;
            if (parsed.merchants) STATE.merchants = parsed.merchants;
            if (parsed.rider) STATE.rider = parsed.rider;
            if (parsed.farmerPayouts) STATE.farmerPayouts = parsed.farmerPayouts;
        }
    } catch (e) {
        console.error("Failed to restore FarmFresh state", e);
    }
})();

window.saveStateToStorage = function() {
    try {
        const select = document.getElementById('user-location-selector');
        localStorage.setItem('FARMFRESH_STATE', JSON.stringify({
            products: STATE.products,
            cart: STATE.cart,
            wishlist: STATE.wishlist,
            orders: STATE.orders,
            addresses: STATE.addresses,
            couponApplied: STATE.couponApplied,
            currentRole: STATE.currentRole,
            merchants: STATE.merchants,
            rider: STATE.rider,
            farmerPayouts: STATE.farmerPayouts || [],
            customerLocation: select ? select.value : (STATE.customerLocation || 'Bengaluru, India')
        }));
    } catch (e) {
        console.error("Failed to save FarmFresh state", e);
    }
};

// Currency State System
let currentCurrencySymbol = '₹';
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
    } else if (activeId === 'screen-farmer-orders') {
        const el = document.getElementById('tab-farmer-orders');
        if (el) el.classList.add('active');
    } else if (activeId === 'screen-farmer-wallet') {
        const el = document.getElementById('tab-farmer-wallet');
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
    saveStateToStorage();
    
    // UI update for role buttons
    document.querySelectorAll('.role-btn').forEach(btn => btn.classList.remove('active'));
    document.getElementById(`btn-role-${role}`).classList.add('active');
    
    Logger.log(`Swapped simulator viewpoint to ${role.toUpperCase()}`, 'system');
    
    // View Switch matching the role
    if (role === 'customer') {
        STATE.activeCategory = 'all';
        STATE.searchQuery = '';
        const searchBox = document.getElementById('product-search-input');
        if (searchBox) searchBox.value = '';
        
        switchScreen('screen-customer-home', 'tab-home');
        renderCategories();
        renderProducts();
    } else if (role === 'farmer') {
        const splash = document.getElementById('farmer-splash-screen');
        if (splash) {
            splash.style.display = 'flex';
            splash.style.opacity = '1';
            
            switchScreen('screen-farmer-dashboard');
            renderFarmerOrders();
            updateFarmerStats();
            renderFarmerInventory();
            
            setTimeout(() => {
                splash.style.transition = 'opacity 0.6s ease';
                splash.style.opacity = '0';
                setTimeout(() => {
                    splash.style.display = 'none';
                }, 600);
            }, 2000);
        } else {
            switchScreen('screen-farmer-dashboard');
            renderFarmerOrders();
            updateFarmerStats();
            renderFarmerInventory();
        }
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
        const isDetailsImage = p.image.includes('/') || p.image.includes('.') || p.image.length > 5;
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
    saveStateToStorage();
    
    // If the wishlist screen is active, re-render it
    if (document.getElementById('screen-customer-wishlist').classList.contains('active')) {
        renderWishlistScreen();
    }
};

// UPDATE WISHLIST BADGE (Now displays Cart Count in Header)
function updateWishlistBadge() {
    const badge = document.getElementById('wishlist-badge-count');
    if (!badge) return;
    
    const count = STATE.cart.reduce((sum, item) => sum + item.quantity, 0);
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
        
        const isDetailsImage = p.image.includes('/') || p.image.includes('.') || p.image.length > 5;
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
    
    // Switch to Cart view
    switchScreen('screen-customer-cart', 'tab-cart');
    
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
    if (product.image.endsWith('.jpg') || product.image.includes('/') || product.image.length > 5) {
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
    
    // Switch to Cart view
    switchScreen('screen-customer-cart', 'tab-cart');
    
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
            if (!p) return sum;
            return sum + (p.price * item.quantity);
        }, 0);
        document.getElementById('onboard-total-price').innerText = formatPrice(sub + 3.99);
    }
    
    syncCartAddress();
    renderCart();
    renderFarmerInventory();
    updateWishlistBadge(); // Keep the header cart badge updated
    saveStateToStorage();
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
        if (!prod) return '';
        
        const imageHtml = (prod.image && (prod.image.endsWith('.jpg') || prod.image.includes('/') || prod.image.length > 5)) 
            ? `<img class="cart-item-img" src="${prod.image}" alt="${prod.name}">` 
            : `<div class="cart-item-img" style="display:flex;align-items:center;justify-content:center;font-size:24px;background:#EAF6EC;">${prod.image || '📦'}</div>`;

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
        if (prod) {
            subtotal += prod.price * item.quantity;
        }
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

        const defaultAddr = (STATE.addresses && STATE.addresses.find(a => a.isDefault)) || { address: 'Santorini Heights, Block C-12, Sector 5' };

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
            address: defaultAddr.address,
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

    // Render order items list on tracking page
    const itemsCard = document.getElementById('tracking-order-items-card');
    if (itemsCard) {
        const itemsHtml = order.items.map(i => {
            const prod = STATE.products.find(p => p.id === i.id) || { image: '📦' };
            const imageHtml = (prod.image && (prod.image.endsWith('.jpg') || prod.image.includes('/') || prod.image.length > 5)) 
                ? `<img src="${prod.image}" style="width:30px; height:30px; border-radius:6px; object-fit:cover; flex-shrink:0;">` 
                : `<span style="font-size:16px; width:30px; height:30px; background:#ECECEC; display:flex; align-items:center; justify-content:center; border-radius:6px; flex-shrink:0;">${prod.image || '📦'}</span>`;
            
            return `
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; font-size:11px; gap:8px;">
                    <div style="display:flex; align-items:center; gap:8px; text-align:left;">
                        ${imageHtml}
                        <div style="display:flex; flex-direction:column;">
                            <span style="font-weight:700; color:var(--text-main); line-height:1.2;">${i.name}</span>
                            <span style="font-size:9px; color:var(--text-muted); margin-top:2px;">${i.quantity} x ${formatPrice(i.price)}</span>
                        </div>
                    </div>
                    <span style="font-weight:700; color:var(--text-main); flex-shrink:0;">${formatPrice(i.price * i.quantity)}</span>
                </div>
            `;
        }).join('');

        itemsCard.innerHTML = `
            <div class="tracking-card" style="margin-top:15px; padding:15px; text-align:left; box-shadow: var(--card-shadow); border-radius: 20px; background: var(--white);">
                <div style="font-size:11px; font-weight:800; color:var(--text-main); margin-bottom:12px; border-bottom:1px solid #F3F3F3; padding-bottom:6px; text-transform:uppercase; letter-spacing:0.5px;">Order Summary</div>
                <div style="display:flex; flex-direction:column; gap:4px;">
                    ${itemsHtml}
                </div>
                <div style="margin-top:10px; border-top:1px dashed #E5EDE7; padding-top:10px; display:flex; flex-direction:column; gap:4px; font-size:10px;">
                    <div style="display:flex; justify-content:space-between; color:var(--text-muted);">
                        <span>Subtotal</span>
                        <span>${formatPrice(order.subtotal)}</span>
                    </div>
                    ${order.discount > 0 ? `
                    <div style="display:flex; justify-content:space-between; color:#C9184A; font-weight:700;">
                        <span>Discount</span>
                        <span>-${formatPrice(order.discount)}</span>
                    </div>` : ''}
                    <div style="display:flex; justify-content:space-between; color:var(--text-muted);">
                        <span>Delivery Fee</span>
                        <span>${formatPrice(order.delivery)}</span>
                    </div>
                    <div style="display:flex; justify-content:space-between; font-weight:800; font-size:12px; color:var(--text-main); margin-top:4px; border-top:1px solid #F3F3F3; padding-top:4px;">
                        <span>Total Paid</span>
                        <span>${formatPrice(order.total)}</span>
                    </div>
                </div>
            </div>
        `;
    }
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
    const orders = STATE.orders;
    
    const newOrders = orders.filter(o => o.status === 'placed');
    const acceptedOrders = orders.filter(o => o.status === 'accepted');

    const badge = document.getElementById('farmer-orders-badge');
    if (badge) badge.innerText = `${newOrders.length + acceptedOrders.length} Pending`;
    
    const countNew = document.getElementById('count-new-orders');
    if (countNew) countNew.innerText = newOrders.length;
    
    const countAccepted = document.getElementById('count-accepted-orders');
    if (countAccepted) countAccepted.innerText = acceptedOrders.length;

    const getItemsHtml = (o) => {
        return o.items.map(i => {
            const prod = STATE.products.find(p => p.id === i.id) || { image: '📦' };
            const imageHtml = (prod.image && (prod.image.endsWith('.jpg') || prod.image.includes('/') || prod.image.length > 5)) 
                ? `<img src="${prod.image}" style="width:20px; height:20px; border-radius:4px; object-fit:cover; flex-shrink:0;">` 
                : `<span style="font-size:12px; width:20px; height:20px; background:#ECECEC; display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0;">${prod.image || '📦'}</span>`;
            
            return `
                <div style="display:flex; align-items:center; justify-content:space-between; font-size:10px; margin-bottom:4px; gap:6px;">
                    <div style="display:flex; align-items:center; gap:6px;">
                        ${imageHtml}
                        <span style="font-weight:700; color:var(--text-main);">${i.quantity}x</span>
                        <span style="color:#555; max-width:120px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">${i.name}</span>
                    </div>
                    <span style="font-weight:700; color:var(--text-main);">${formatPrice(i.price * i.quantity)}</span>
                </div>
            `;
        }).join('');
    };

    const getTotalQty = (o) => {
        return o.items.reduce((sum, i) => sum + i.quantity, 0);
    };

    const newOrdersHtml = newOrders.length === 0
        ? '<div style="font-size:11px; text-align:center; padding: 15px; color:var(--text-muted); background:var(--white); border-radius:12px; border:1px solid #EAEAEA;">No new incoming orders.</div>'
        : newOrders.map(o => {
            const cName = o.customerName || 'Ritih';
            const cPhone = o.customerPhone || '+91 98765 43210';
            const payStatus = o.paymentStatus || 'Paid';
            const oDateTime = o.orderDateTime || ('Today, ' + o.timestamp);
            
            return `
                <div class="order-card-merchant" style="border-left: 4px solid var(--primary); margin-bottom: 10px;">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #EEE; padding-bottom:6px; margin-bottom:8px;">
                        <span style="font-weight:900; color:var(--text-main); font-size:12px;">#${o.id}</span>
                        <span style="font-size:10px; background:#FFF3CD; color:#856404; padding:2px 6px; border-radius:6px; font-weight:700;">New Order</span>
                    </div>
                    
                    <div style="display:flex; flex-direction:column; gap:4px; font-size:10px; color:#555; margin-bottom:8px; border-bottom:1px dashed #EEE; padding-bottom:8px;">
                        <div><strong>Customer:</strong> ${cName}</div>
                        <div><strong>Phone:</strong> ${cPhone}</div>
                        <div><strong>Address:</strong> ${o.address}</div>
                        <div><strong>Date & Time:</strong> ${oDateTime}</div>
                        <div style="display:flex; justify-content:space-between; margin-top:2px;">
                            <span><strong>Method:</strong> ${o.paymentMethod.toUpperCase()}</span>
                            <span><strong>Status:</strong> <span style="color:#2E7D32; font-weight:700;">${payStatus}</span></span>
                        </div>
                    </div>
                    
                    <div style="font-size: 10px; font-weight: 800; margin-bottom: 6px;">Ordered Items (${getTotalQty(o)} pcs):</div>
                    <div class="order-card-items-list" style="margin-bottom: 8px;">
                        ${getItemsHtml(o)}
                    </div>
                    
                    <div style="display:flex; justify-content:space-between; align-items:center; border-top:1px solid #EEE; padding-top:8px; margin-top:6px;">
                        <div>
                            <div style="font-size:8px; color:var(--text-muted); text-transform:uppercase;">Order Total</div>
                            <div style="font-size:14px; font-weight:900; color:var(--green-dark);">${formatPrice(o.total)}</div>
                        </div>
                        <div style="display:flex; gap:6px;">
                            <button class="btn-action-small" style="background:#fee2e2; color:#ef4444; border:none;" onclick="farmerRejectOrder('${o.id}')">Reject</button>
                            <button class="btn-action-small" onclick="farmerAcceptOrder('${o.id}')">Accept</button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');

    const acceptedOrdersHtml = acceptedOrders.length === 0
        ? '<div style="font-size:11px; text-align:center; padding: 15px; color:var(--text-muted); background:var(--white); border-radius:12px; border:1px solid #EAEAEA;">No accepted orders.</div>'
        : acceptedOrders.map(o => {
            const cName = o.customerName || 'Ritih';
            const cPhone = o.customerPhone || '+91 98765 43210';
            const payStatus = o.paymentStatus || 'Paid';
            const estPickup = o.estimatedPickup || 'Within 30 mins';
            
            return `
                <div class="order-card-merchant" style="border-left: 4px solid #D68C45; margin-bottom: 10px;">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #EEE; padding-bottom:6px; margin-bottom:8px;">
                        <span style="font-weight:900; color:var(--text-main); font-size:12px;">#${o.id}</span>
                        <span style="font-size:10px; background:#D1E7DD; color:#0F5132; padding:2px 6px; border-radius:6px; font-weight:700;">Accepted</span>
                    </div>
                    
                    <div style="display:flex; flex-direction:column; gap:4px; font-size:10px; color:#555; margin-bottom:8px; border-bottom:1px dashed #EEE; padding-bottom:8px;">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <span><strong>Customer:</strong> ${cName}</span>
                            <button onclick="startCallSimulation('${cName}', '${cPhone}')" style="background:#EAF6EC; color:#2E7D32; border:none; padding:2px 6px; border-radius:6px; font-weight:700; font-size:9px; cursor:pointer; display:flex; align-items:center; gap:4px;">
                                <i class="fa-solid fa-phone"></i> Call
                            </button>
                        </div>
                        <div><strong>Phone:</strong> ${cPhone}</div>
                        <div><strong>Address:</strong> ${o.address}</div>
                        <div style="color:#d97706; font-weight:700;"><strong>Est. Pickup Time:</strong> ${estPickup}</div>
                        <div style="display:flex; justify-content:space-between; margin-top:2px;">
                            <span><strong>Method:</strong> ${o.paymentMethod.toUpperCase()}</span>
                            <span><strong>Status:</strong> <span style="color:#2E7D32; font-weight:700;">${payStatus}</span></span>
                        </div>
                    </div>
                    
                    <div style="font-size: 10px; font-weight: 800; margin-bottom: 6px;">Ordered Items (${getTotalQty(o)} pcs):</div>
                    <div class="order-card-items-list" style="margin-bottom: 8px;">
                        ${getItemsHtml(o)}
                    </div>
                    
                    <div style="display:flex; justify-content:space-between; align-items:center; border-top:1px solid #EEE; padding-top:8px; margin-top:6px;">
                        <div>
                            <div style="font-size:8px; color:var(--text-muted); text-transform:uppercase;">Order Total</div>
                            <div style="font-size:14px; font-weight:900; color:var(--green-dark);">${formatPrice(o.total)}</div>
                        </div>
                        <button class="btn-action-small" style="background:var(--primary-gradient); color:white;" onclick="farmerPrepareOrder('${o.id}')">Ready for Packing</button>
                    </div>
                </div>
            `;
        }).join('');

    const containerNew = document.getElementById('farmer-new-orders-list');
    if (containerNew) containerNew.innerHTML = newOrdersHtml;

    const containerAccepted = document.getElementById('farmer-accepted-orders-list');
    if (containerAccepted) containerAccepted.innerHTML = acceptedOrdersHtml;

    const dashboardContainer = document.getElementById('farmer-orders-list');
    if (dashboardContainer) {
        if (newOrders.length === 0 && acceptedOrders.length === 0) {
            dashboardContainer.innerHTML = '<div style="font-size:11px; text-align:center; padding: 20px; color:var(--text-muted);">No active pending orders.</div>';
        } else {
            dashboardContainer.innerHTML = `
                <div style="display:flex; flex-direction:column; gap:10px;">
                    ${newOrders.map(o => `
                        <div style="display:flex; justify-content:space-between; align-items:center; background:var(--white); border:1px solid #EAEAEA; padding:8px 12px; border-radius:12px; font-size:11px;">
                            <div>
                                <span style="font-weight:700;">#${o.id}</span>
                                <span style="font-size:9px; color:var(--text-muted); margin-left:6px;">New order from ${o.customerName || 'Ritih'}</span>
                            </div>
                            <button class="btn-action-small" onclick="switchFarmerTab('screen-farmer-orders')">Manage</button>
                        </div>
                    `).join('')}
                    ${acceptedOrders.map(o => `
                        <div style="display:flex; justify-content:space-between; align-items:center; background:var(--white); border:1px solid #EAEAEA; padding:8px 12px; border-radius:12px; font-size:11px;">
                            <div>
                                <span style="font-weight:700;">#${o.id}</span>
                                <span style="font-size:9px; color:#d97706; margin-left:6px;">Accepted - packing pending</span>
                            </div>
                            <button class="btn-action-small" onclick="switchFarmerTab('screen-farmer-orders')">Pack</button>
                        </div>
                    `).join('')}
                </div>
            `;
        }
    }
}

window.renderFarmerWallet = function() {
    const merchant = STATE.merchants[0]; // Organico Farm
    
    // Update earnings display
    const balanceDisplay = document.getElementById('farmer-wallet-balance-display');
    if (balanceDisplay) {
        balanceDisplay.innerText = formatPrice(merchant.earnings);
    }
    
    // Render transaction history list
    const listContainer = document.getElementById('farmer-wallet-transactions-list');
    if (!listContainer) return;
    
    const completedOrders = STATE.orders.filter(o => o.status === 'completed');
    
    if (completedOrders.length === 0 && (!STATE.farmerPayouts || STATE.farmerPayouts.length === 0)) {
        listContainer.innerHTML = '<div style="font-size:11px; text-align:center; color:var(--text-muted); padding: 15px; background:var(--white); border-radius: 12px; border: 1px solid #EAEAEA;">No wallet history yet.</div>';
        return;
    }
    
    // Combine completed orders credit and debit payouts
    let txs = completedOrders.map(o => {
        const deliveryFee = 3.99;
        const farmerEarnings = o.total - deliveryFee;
        return {
            title: `Order #${o.id} Credit`,
            amount: `+${formatPrice(farmerEarnings)}`,
            time: o.timestamp || 'Today',
            type: 'credit'
        };
    });
    
    if (STATE.farmerPayouts) {
        STATE.farmerPayouts.forEach(p => {
            txs.push({
                title: 'Withdrawal to Bank',
                amount: `-${formatPrice(p.amount)}`,
                time: p.time,
                type: 'debit'
            });
        });
    }
    
    // Render list
    listContainer.innerHTML = txs.map(t => {
        const color = t.type === 'credit' ? '#2E7D32' : '#EF4444';
        const signStyle = t.type === 'credit' ? 'font-weight:700;' : 'font-weight:700;';
        return `
            <div style="display:flex; justify-content:space-between; align-items:center; background:var(--white); border:1px solid #EAEAEA; padding:8px 12px; border-radius:12px; font-size:11px; margin-bottom:6px;">
                <div>
                    <div style="font-weight:700; color:var(--text-main);">${t.title}</div>
                    <div style="font-size:9px; color:var(--text-muted); margin-top:2px;">${t.time}</div>
                </div>
                <div style="color:${color}; ${signStyle}">${t.amount}</div>
            </div>
        `;
    }).join('');
};

window.farmerRequestPayout = function() {
    const merchant = STATE.merchants[0]; // Organico Farm
    if (merchant.earnings <= 0) {
        showToast('No earnings balance to withdraw! 💸');
        return;
    }
    
    const amount = merchant.earnings;
    
    // Add transaction to history
    if (!STATE.farmerPayouts) STATE.farmerPayouts = [];
    STATE.farmerPayouts.push({
        amount: amount,
        time: new Date().toLocaleTimeString()
    });
    
    // Reset balance
    merchant.earnings = 0;
    
    // Save, update UI
    saveStateToStorage();
    updateFarmerStats();
    renderFarmerWallet();
    showToast(`Withdrawal of ${formatPrice(amount)} requested! 🏦`);
    Logger.log(`Farmer requested bank payout of ${formatPrice(amount)}. Account balance reset.`, 'farmer');
};

function renderFarmerInventory() {
    const container = document.getElementById('farmer-inventory-list');
    if (!container) return;
    
    const farmerProds = STATE.products.filter(p => p.addedByFarmer === true);
    
    if (farmerProds.length === 0) {
        container.innerHTML = `<div style="font-size:11px; color:var(--text-muted); text-align:center; padding:15px; background:var(--white); border-radius:12px; border:1px solid #EAEAEA;">No products added yet.</div>`;
        return;
    }
    
    container.innerHTML = farmerProds.map(p => {
        let priceStr = typeof p.price === 'number' ? `$${p.price.toFixed(2)}` : p.price;
        const inCart = STATE.cart.some(item => item.productId === p.id);
        const addBtnHtml = inCart 
            ? `<button class="btn-action-small" style="background:#E0EAE2; color:#555; border:none; padding:4px 8px; font-weight:700;" onclick="farmerAddAndVisitProduct('${p.id}')">Added ✓</button>`
            : `<button class="btn-action-small" style="background:#EAF6EC; color:#2E7D32; border:none; padding:4px 8px; font-weight:700;" onclick="farmerAddAndVisitProduct('${p.id}')">Add</button>`;
            
        return `
            <div class="order-card-merchant" style="margin-bottom:8px; display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <div style="font-weight:700; font-size:12px;">${p.name}</div>
                    <div style="font-size:10px; color:var(--text-muted);">${p.weight} | ${priceStr}</div>
                </div>
                <div style="display:flex; gap:6px;">
                    ${addBtnHtml}
                    <button class="btn-action-small" style="background:#fee2e2; color:#ef4444; border:none; padding:4px 8px;" onclick="farmerDeleteProduct('${p.id}')">Delete</button>
                </div>
            </div>
        `;
    }).join('');
}

window.farmerAddAndVisitProduct = function(pId) {
    const product = STATE.products.find(p => p.id === pId);
    if (!product) return;
    
    const existing = STATE.cart.find(item => item.productId === pId);
    if (existing) {
        switchRole('customer');
        switchScreen('screen-customer-cart', 'tab-cart');
        showToast(`${product.name} is already added! 🛒`);
        Logger.log(`Farmer visited customer view. Product "${product.name}" was already in customer cart.`, 'farmer');
    } else {
        STATE.cart.push({ productId: pId, quantity: 1 });
        updateCartStats();
        switchRole('customer');
        switchScreen('screen-customer-cart', 'tab-cart');
        showToast(`${product.name} added to cart! 🛒`);
        Logger.log(`Farmer added "${product.name}" to customer cart and switched view.`, 'farmer');
    }
};

window.farmerDeleteProduct = function(pId) {
    STATE.products = STATE.products.filter(p => p.id !== pId);
    STATE.cart = STATE.cart.filter(item => item.productId !== pId);
    STATE.wishlist = STATE.wishlist.filter(id => id !== pId);
    
    renderFarmerInventory();
    renderProducts();
    updateCartStats();
    Logger.log(`Farmer deleted product ID: ${pId} from online market.`, 'farmer');
};


window.farmerAcceptOrder = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'accepted';
    Logger.log(`Farmer accepted order #${orderId}. Preparing products for packaging...`, 'farmer');
    renderFarmerOrders();
    saveStateToStorage();
    
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
    saveStateToStorage();
    
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
        const itemsListHtml = o.items.map(i => {
            const prod = STATE.products.find(p => p.id === i.id) || { image: '📦' };
            const imageHtml = (prod.image && (prod.image.endsWith('.jpg') || prod.image.includes('/') || prod.image.length > 5)) 
                ? `<img src="${prod.image}" style="width:20px; height:20px; border-radius:4px; object-fit:cover; flex-shrink:0;">` 
                : `<span style="font-size:12px; width:20px; height:20px; background:#ECECEC; display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0;">${prod.image || '📦'}</span>`;
            
            return `
                <div style="display:flex; align-items:center; justify-content:space-between; font-size:10px; margin-bottom:4px; gap:6px; text-align:left;">
                    <div style="display:flex; align-items:center; gap:6px;">
                        ${imageHtml}
                        <span style="font-weight:700; color:var(--text-main);">${i.quantity}x</span>
                        <span style="color:#555; max-width:120px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">${i.name}</span>
                    </div>
                    <span style="font-weight:700; color:var(--text-main);">${formatPrice(i.price * i.quantity)}</span>
                </div>
            `;
        }).join('');

        return `
            <div class="order-card-merchant">
                <div class="order-card-header">
                    <span style="font-weight:700;">#${o.id}</span>
                    <span style="color:#2E7D32;">Prepared</span>
                </div>
                <div class="order-card-items-list" style="display:flex; flex-direction:column; gap:2px; margin:6px 0; border-bottom:1px dashed #EEE; padding-bottom:6px;">
                    ${itemsListHtml}
                </div>
                <div class="order-card-footer" style="margin-top:4px;">
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
    saveStateToStorage();
    
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
        saveStateToStorage();
        
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
    
    // Image Mapping & Fallbacks System
    const IMAGE_MAPPING = {
        'potato': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80',
        'potatoes': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80',
        'onion': 'https://images.unsplash.com/photo-1508747703725-719ae257c26a?w=500&auto=format&fit=crop&q=80',
        'onions': 'https://images.unsplash.com/photo-1508747703725-719ae257c26a?w=500&auto=format&fit=crop&q=80',
        'grapes': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=500&auto=format&fit=crop&q=80',
        'grape': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=500&auto=format&fit=crop&q=80',
        'mango': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500&auto=format&fit=crop&q=80',
        'mangoes': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500&auto=format&fit=crop&q=80',
        'banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
        'bananas': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
        'cabbage': 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ec3?w=500&auto=format&fit=crop&q=80',
        'garlic': 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=500&auto=format&fit=crop&q=80',
        'ginger': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500&auto=format&fit=crop&q=80',
        'lemon': 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=500&auto=format&fit=crop&q=80',
        'lemons': 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=500&auto=format&fit=crop&q=80',
        'pineapple': 'https://images.unsplash.com/photo-1550258224-2ae379198519?w=500&auto=format&fit=crop&q=80',
        'pineapples': 'https://images.unsplash.com/photo-1550258224-2ae379198519?w=500&auto=format&fit=crop&q=80',
        'watermelon': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&auto=format&fit=crop&q=80',
        'watermelons': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&auto=format&fit=crop&q=80',
        'pomegranate': 'https://images.unsplash.com/photo-1541344999736-83eca872977a?w=500&auto=format&fit=crop&q=80',
        'pear': 'https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=500&auto=format&fit=crop&q=80',
        'pears': 'https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=500&auto=format&fit=crop&q=80',
        'peach': 'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?w=500&auto=format&fit=crop&q=80',
        'peaches': 'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?w=500&auto=format&fit=crop&q=80',
        'tomato': 'assets/cherry_tomatoes.jpg',
        'tomatoes': 'assets/cherry_tomatoes.jpg',
        'carrot': 'assets/organic_carrots.jpg',
        'carrots': 'assets/organic_carrots.jpg',
        'spinach': 'assets/baby_spinach.jpg',
        'cucumber': 'assets/english_cucumbers.jpg',
        'cucumbers': 'assets/english_cucumbers.jpg',
        'apple': 'assets/crisp_red_apples.jpg',
        'apples': 'assets/crisp_red_apples.jpg',
        'blueberries': 'assets/fresh_blueberries.jpg',
        'blueberry': 'assets/fresh_blueberries.jpg',
        'eggs': 'assets/fresh_farm_eggs.jpg',
        'egg': 'assets/fresh_farm_eggs.jpg',
        'butter': 'assets/grassfed_butter.jpg',
        'milk': 'assets/organic_whole_milk.jpg',
        'steak': 'assets/ribeye_steak.jpg',
        'beef': 'assets/ribeye_steak.jpg',
        'salmon': 'assets/salmon_fillet.jpg',
        'fish': 'assets/salmon_fillet.jpg',
        'chicken': 'assets/chicken_breast.jpg',
        'avocado': 'assets/hass_avocados.jpg',
        'avocados': 'assets/hass_avocados.jpg',
        'orange': 'assets/organic_oranges.jpg',
        'oranges': 'assets/organic_oranges.jpg',
        'broccoli': 'assets/organic_broccolini.jpg',
        'broccolini': 'assets/organic_broccolini.jpg',
        'strawberry': 'assets/organic_strawberries.jpg',
        'strawberries': 'assets/organic_strawberries.jpg',
    };

    const categoryFallbacks = {
        'vegetables': 'https://images.unsplash.com/photo-1566385962061-f24cedde3a2c?w=500&auto=format&fit=crop&q=80',
        'fruits': 'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?w=500&auto=format&fit=crop&q=80',
        'meat': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&auto=format&fit=crop&q=80',
        'dairy': 'https://images.unsplash.com/photo-1528498033373-3c6c08e93d79?w=500&auto=format&fit=crop&q=80'
    };

    function publishFarmerProduct(productImg) {
        const newProd = {
            id: `prod-${Date.now()}`,
            name: name,
            price: price,
            originalPrice: price,
            discount: null,
            origin: 'Organico Farm, US',
            category: category,
            image: productImg,
            description: `Freshly harvested organic ${name} grown by local farmers at Organico Farm. Packed carefully for delivery.`,
            calories: '120 kcal',
            protein: '3 gram',
            fat: '0 gram',
            weight: weight,
            addedByFarmer: true
        };
        
        STATE.products.push(newProd);
        
        // Clear forms
        document.getElementById('form-new-pname').value = '';
        document.getElementById('form-new-price').value = '';
        document.getElementById('form-new-unit').value = '';
        const fileInput = document.getElementById('form-new-image-file');
        if (fileInput) fileInput.value = '';
        
        Logger.log(`Farmer published new product harvest: "${name}" ($${price.toFixed(2)} per ${weight}) to storefront.`, 'farmer');
        
        // Rerender grids
        renderProducts();
        renderFarmerInventory();
        Notification.show('New Harvest Item!', `Merchant published ${name} to the online market.`);
        
        // Automatically switch viewpoint to customer view to see the new item
        setTimeout(() => {
            switchRole('customer');
            showToast(`Switched to Customer view to see your published ${name}! 🍏`);
        }, 850);
    }

    // Check for custom file upload
    const fileInput = document.getElementById('form-new-image-file');
    if (fileInput && fileInput.files && fileInput.files[0]) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        reader.onload = function(e) {
            publishFarmerProduct(e.target.result);
        };
        reader.readAsDataURL(file);
    } else {
        // Resolve using smart noun extraction and mapping lookup
        const cleanName = name.toLowerCase();
        
        // List of common farm keywords to search for
        const knownKeywords = [
            'potato', 'potatoes', 'onion', 'onions', 'grapes', 'grape', 'tomato', 'tomatoes', 
            'carrot', 'carrots', 'spinach', 'cucumber', 'cucumbers', 'apple', 'apples', 
            'blueberry', 'blueberries', 'egg', 'eggs', 'butter', 'milk', 'steak', 'beef', 
            'salmon', 'fish', 'chicken', 'avocado', 'avocados', 'orange', 'oranges', 
            'broccoli', 'broccolini', 'strawberry', 'strawberries', 'banana', 'bananas', 
            'mango', 'mangoes', 'cabbage', 'garlic', 'ginger', 'lemon', 'lemons', 
            'pineapple', 'pineapples', 'watermelon', 'pomegranate', 'pear', 'pears', 
            'peach', 'peaches', 'plum', 'plums', 'berry', 'berries', 'cheese', 'yogurt'
        ];
        
        let matchedKeyword = knownKeywords.find(keyword => cleanName.includes(keyword));
        let queryWord = '';
        
        if (matchedKeyword) {
            queryWord = matchedKeyword;
        } else {
            // Extract the last word (the noun, e.g. "Grapes" in "Punjab Grapes")
            const words = cleanName.replace(/[^a-z0-9\s]/g, '').trim().split(/\s+/);
            queryWord = words[words.length - 1] || 'vegetable';
        }
        
        let productImg = '';
        if (IMAGE_MAPPING[queryWord]) {
            productImg = IMAGE_MAPPING[queryWord];
        } else {
            // Dynamic real/stock image lookup using LoremFlickr for the specific base product noun
            productImg = `https://loremflickr.com/500/500/${encodeURIComponent(queryWord)},organic,fresh/all`;
        }
        
        publishFarmerProduct(productImg);
    }
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
document.getElementById('tab-farmer-orders').addEventListener('click', () => {
    switchScreen('screen-farmer-orders');
    renderFarmerOrders();
});
document.getElementById('tab-farmer-wallet').addEventListener('click', () => {
    switchScreen('screen-farmer-wallet');
    renderFarmerWallet();
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
    currentCurrencySymbol = '₹';
    currentCurrencyRate = 1.0;
    Logger.log(`Location switched to ${val}. Currency set to Rupees (₹)`, 'customer');
    
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
    if (!STATE.addresses) {
        STATE.addresses = [
            {
                id: 'addr-1',
                tag: 'Home 🏠',
                address: 'Santorini Heights, Block C-12, Sector 5',
                instructions: 'Ring bell, leave on doorstep.',
                isDefault: true
            },
            {
                id: 'addr-2',
                tag: 'Office 💼',
                address: 'Tech Hub Plaza, Tower B, 4th Floor',
                instructions: '',
                isDefault: false
            }
        ];
    }

    let addressCardsHtml = STATE.addresses.map(addr => {
        const borderStyle = addr.isDefault ? 'border:1.5px solid var(--green-light); background:#F9FBF9;' : 'border:1px solid #ECECEC; background:var(--white);';
        const defaultBadge = addr.isDefault ? '<span style="float:right; font-size:8px; background:var(--green-light); color:var(--green-dark); padding:2px 6px; border-radius:10px; font-weight:800; line-height:1;">DEFAULT</span>' : '';
        const instructionsHtml = addr.instructions ? `<span style="color:#888; font-size:9px; display:block; margin-top:4px;">Instructions: ${addr.instructions}</span>` : '';
        
        return `
            <div style="${borderStyle} border-radius:12px; padding:12px; position:relative; margin-bottom:10px; box-shadow:0 2px 6px rgba(0,0,0,0.02); text-align:left;">
                ${defaultBadge}
                <span style="font-weight:700; color:var(--text-main); display:block; font-size:11px; cursor:pointer;" onclick="setDefaultAddress('${addr.id}')">${addr.tag}</span>
                <span style="color:#555; display:block; margin-top:2px; font-size:10px; cursor:pointer; line-height:1.3;" onclick="setDefaultAddress('${addr.id}')">${addr.address}</span>
                ${instructionsHtml}
                <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:6px; border-top:1px dashed #EEE; padding-top:6px;">
                    ${!addr.isDefault ? `<button onclick="setDefaultAddress('${addr.id}')" style="border:none; background:transparent; color:var(--green-dark); font-size:9px; font-weight:800; cursor:pointer; padding:0;">Set Default</button>` : ''}
                    <button onclick="deleteSavedAddress('${addr.id}')" style="border:none; background:transparent; color:#C9184A; font-size:9px; font-weight:800; cursor:pointer; padding:0;">Delete</button>
                </div>
            </div>
        `;
    }).join('');

    if (STATE.addresses.length === 0) {
        addressCardsHtml = `<div style="text-align:center; padding:20px 10px; font-size:11px; color:#888;">No saved addresses. Add one below!</div>`;
    }

    const html = `
        <div style="display:flex; flex-direction:column; max-height:360px; overflow-y:auto; padding-right:2px;">
            ${addressCardsHtml}
            <button onclick="openAddNewAddressForm()" class="btn-primary-gradient" style="height:38px; border-radius:12px; font-size:11px; margin-top:8px; cursor:pointer; border:none; width:100%; font-weight:700;">Add New Address</button>
        </div>
    `;
    openAccountModal('Saved Addresses', html);
};

window.syncCartAddress = function() {
    if (!STATE.addresses) {
        STATE.addresses = [
            {
                id: 'addr-1',
                tag: 'Home 🏠',
                address: 'Santorini Heights, Block C-12, Sector 5',
                instructions: 'Ring bell, leave on doorstep.',
                isDefault: true
            },
            {
                id: 'addr-2',
                tag: 'Office 💼',
                address: 'Tech Hub Plaza, Tower B, 4th Floor',
                instructions: '',
                isDefault: false
            }
        ];
    }
    
    const defaultAddr = STATE.addresses.find(a => a.isDefault) || STATE.addresses[0];
    const tagEl = document.getElementById('cart-selected-address-tag');
    const textEl = document.getElementById('cart-selected-address-text');
    
    if (defaultAddr && tagEl && textEl) {
        tagEl.innerText = defaultAddr.tag;
        textEl.innerText = defaultAddr.address;
    }
};

window.setDefaultAddress = function(addrId) {
    STATE.addresses.forEach(addr => {
        addr.isDefault = (addr.id === addrId);
    });
    showToast('Default address updated!');
    Logger.log(`Customer changed default delivery address to: "${STATE.addresses.find(a => a.id === addrId).tag}"`, 'customer');
    syncCartAddress();
    openProfileAddresses();
};

window.deleteSavedAddress = function(addrId) {
    const addr = STATE.addresses.find(a => a.id === addrId);
    if (addr.isDefault) {
        showToast('Cannot delete default address!');
        return;
    }
    STATE.addresses = STATE.addresses.filter(a => a.id !== addrId);
    showToast('Address deleted!');
    Logger.log(`Customer removed saved address: "${addr.tag}"`, 'customer');
    syncCartAddress();
    openProfileAddresses();
};

window.openAddNewAddressForm = function() {
    const html = `
        <div style="display:flex; flex-direction:column; gap:10px; text-align:left; max-height:380px; overflow-y:auto; padding-right:4px;">
            <div class="input-field-group" style="margin:0;">
                <label style="font-size: 9px; margin-bottom: 2px; font-weight:800; color:var(--text-muted); text-transform:uppercase;">Address Tag</label>
                <input type="text" class="input-box" id="new-addr-tag" placeholder="e.g. Home 🏠, Office 💼" style="height: 32px; font-size: 11px; padding:0 10px; border-radius:10px;">
            </div>
            
            <!-- Inline Auto-detect Location Button -->
            <button onclick="detectLocationInForm()" class="btn-detect-location-custom" id="btn-form-detect-loc">
                <i class="fa-solid fa-location-crosshairs"></i> Use Current Location
            </button>
            
            <div class="input-field-group" style="margin:0;">
                <label style="font-size: 9px; margin-bottom: 2px; font-weight:800; color:var(--text-muted); text-transform:uppercase;">Address Line 1 (Full Address)</label>
                <input type="text" class="input-box" id="new-addr-line1" placeholder="Flat/House No, Building, Street, Area" style="height: 32px; font-size: 11px; padding:0 10px; border-radius:10px;">
            </div>
            
            <div style="display:flex; gap:8px; margin:0;">
                <div class="input-field-group" style="flex:1; margin:0;">
                    <label style="font-size: 9px; margin-bottom: 2px; font-weight:800; color:var(--text-muted); text-transform:uppercase;">Landmark</label>
                    <input type="text" class="input-box" id="new-addr-landmark" placeholder="e.g. Near Park" style="height: 32px; font-size: 11px; padding:0 10px; border-radius:10px;">
                </div>
                <div class="input-field-group" style="flex:1; margin:0;">
                    <label style="font-size: 9px; margin-bottom: 2px; font-weight:800; color:var(--text-muted); text-transform:uppercase;">Pincode</label>
                    <input type="text" class="input-box" id="new-addr-pincode" placeholder="e.g. 400001" style="height: 32px; font-size: 11px; padding:0 10px; border-radius:10px;">
                </div>
            </div>
            
            <div class="input-field-group" style="margin:0;">
                <label style="font-size: 9px; margin-bottom: 2px; font-weight:800; color:var(--text-muted); text-transform:uppercase;">Rider Instructions (Optional)</label>
                <input type="text" class="input-box" id="new-addr-instructions" placeholder="e.g. Leave with guard" style="height: 32px; font-size: 11px; padding:0 10px; border-radius:10px;">
            </div>
            
            <div style="display:flex; gap:10px; margin-top:8px;">
                <button onclick="openProfileAddresses()" style="flex:1; height:36px; background:#ECECEC; color:#555; border:none; border-radius:12px; font-weight:700; cursor:pointer; font-size:11px;">Cancel</button>
                <button onclick="saveNewAddress()" class="btn-primary-gradient" style="flex:1; height:36px; font-size:11px; cursor:pointer; border:none; font-weight:700; border-radius:12px;">Save Address</button>
            </div>
        </div>
    `;
    openAccountModal('Add New Address', html);
};

window.detectLocationInForm = function() {
    const btn = document.getElementById('btn-form-detect-loc');
    if (!btn) return;
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Locating...';
    btn.disabled = true;

    if (!navigator.geolocation) {
        fetchIpLocationForForm(btn, originalText);
        return;
    }

    navigator.geolocation.getCurrentPosition(
        function(position) {
            const lat = position.coords.latitude;
            const lon = position.coords.longitude;
            
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`)
                .then(res => res.json())
                .then(data => {
                    let road = data.address.road || data.address.suburb || data.address.neighbourhood || '';
                    let city = data.address.city || data.address.town || data.address.village || '';
                    let state = data.address.state || '';
                    let country = data.address.country || '';
                    let pincode = data.address.postcode || '';
                    
                    let parts = [];
                    if (road) parts.push(road);
                    if (city) parts.push(city);
                    if (state) parts.push(state);
                    if (country) parts.push(country);
                    
                    let line1 = parts.join(', ');
                    
                    const line1Input = document.getElementById('new-addr-line1');
                    const pinInput = document.getElementById('new-addr-pincode');
                    
                    if (line1Input) line1Input.value = line1;
                    if (pinInput && pincode) pinInput.value = pincode;
                    
                    btn.innerHTML = originalText;
                    btn.disabled = false;
                    showToast('Location detected successfully! 📍');
                })
                .catch(() => {
                    let line1 = `${lat.toFixed(4)}°N, ${lon.toFixed(4)}°E`;
                    const line1Input = document.getElementById('new-addr-line1');
                    if (line1Input) line1Input.value = line1;
                    
                    btn.innerHTML = originalText;
                    btn.disabled = false;
                    showToast('Location coordinates captured! 📍');
                });
        },
        function(error) {
            fetchIpLocationForForm(btn, originalText);
        },
        { timeout: 7000 }
    );
};

function fetchIpLocationForForm(btn, originalText) {
    fetch('https://ipapi.co/json/')
        .then(res => res.json())
        .then(data => {
            let line1 = '';
            if (data.city && data.region) {
                line1 = `${data.city}, ${data.region}, ${data.country_name}`;
            } else {
                line1 = data.city || '';
            }
            
            const line1Input = document.getElementById('new-addr-line1');
            const pinInput = document.getElementById('new-addr-pincode');
            
            if (line1Input) line1Input.value = line1;
            if (pinInput && data.postal) pinInput.value = data.postal;
            
            btn.innerHTML = originalText;
            btn.disabled = false;
            showToast('IP Location detected! 📍');
        })
        .catch(() => {
            showToast('Location detection failed. Enter manually!');
            btn.innerHTML = originalText;
            btn.disabled = false;
        });
}

window.saveNewAddress = function() {
    const tagVal = document.getElementById('new-addr-tag').value.trim();
    const line1Val = document.getElementById('new-addr-line1').value.trim();
    const landmarkVal = document.getElementById('new-addr-landmark').value.trim();
    const pincodeVal = document.getElementById('new-addr-pincode').value.trim();
    const instrVal = document.getElementById('new-addr-instructions').value.trim();

    if (!tagVal || !line1Val || !pincodeVal) {
        showToast('Please fill Tag, Line 1 Address, and Pincode!');
        return;
    }

    // Neat composition of full address: Line 1, Landmark (Optional) - Pincode
    let fullAddress = line1Val;
    if (landmarkVal) {
        fullAddress += `, near ${landmarkVal}`;
    }
    fullAddress += ` - ${pincodeVal}`;

    const newAddr = {
        id: `addr-${Date.now()}`,
        tag: tagVal,
        address: fullAddress,
        instructions: instrVal,
        isDefault: STATE.addresses.length === 0
    };

    STATE.addresses.push(newAddr);
    showToast('Address saved successfully!');
    Logger.log(`Customer saved new address: "${tagVal}" - "${fullAddress}"`, 'customer');
    
    syncCartAddress();
    openProfileAddresses();
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

// CUSTOM ADD LOCATION MODAL FUNCTIONS
window.openAddLocationModal = function() {
    const modal = document.getElementById('modal-add-location');
    if (modal) {
        modal.style.display = 'flex';
        document.getElementById('input-custom-location').value = '';
    }
};

window.closeAddLocationModal = function() {
    const modal = document.getElementById('modal-add-location');
    if (modal) modal.style.display = 'none';
};

window.saveCustomLocation = function() {
    const input = document.getElementById('input-custom-location');
    if (!input) return;
    const val = input.value.trim();
    if (!val) {
        showToast('Please enter a location name!');
        return;
    }
    addAndSelectUserLocation(val);
    closeAddLocationModal();
    showToast(`Location added: ${val}! 📍`);
};

window.detectCurrentLocation = function() {
    const btn = document.getElementById('btn-detect-loc');
    if (!btn) return;
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Detecting...';
    btn.disabled = true;

    if (!navigator.geolocation) {
        fetchIpLocation(btn, originalText);
        return;
    }

    navigator.geolocation.getCurrentPosition(
        function(position) {
            const lat = position.coords.latitude;
            const lon = position.coords.longitude;
            
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`)
                .then(res => res.json())
                .then(data => {
                    let city = data.address.city || data.address.town || data.address.village || data.address.suburb || 'Current Location';
                    let country = data.address.country || '';
                    let locationName = country ? `${city}, ${country}` : city;
                    
                    addAndSelectUserLocation(locationName);
                    btn.innerHTML = originalText;
                    btn.disabled = false;
                    closeAddLocationModal();
                    showToast(`Located: ${locationName}! 📍`);
                })
                .catch(() => {
                    let locationName = `${lat.toFixed(2)}°N, ${lon.toFixed(2)}°E`;
                    addAndSelectUserLocation(locationName);
                    btn.innerHTML = originalText;
                    btn.disabled = false;
                    closeAddLocationModal();
                    showToast(`Located: ${locationName}! 📍`);
                });
        },
        function(error) {
            fetchIpLocation(btn, originalText);
        },
        { timeout: 7000 }
    );
};

function fetchIpLocation(btn, originalText) {
    fetch('https://ipapi.co/json/')
        .then(res => res.json())
        .then(data => {
            if (data.city && data.country_name) {
                let locationName = `${data.city}, ${data.country_name}`;
                addAndSelectUserLocation(locationName);
                showToast(`Located: ${locationName}! 📍`);
            } else {
                showToast('Could not detect location. Enter manually!');
            }
            btn.innerHTML = originalText;
            btn.disabled = false;
            closeAddLocationModal();
        })
        .catch(() => {
            showToast('Location detection failed. Enter manually!');
            btn.innerHTML = originalText;
            btn.disabled = false;
        });
}

window.addAndSelectUserLocation = function(name) {
    const select = document.getElementById('user-location-selector');
    if (!select) return;
    
    let exists = false;
    for (let i = 0; i < select.options.length; i++) {
        if (select.options[i].value.toLowerCase() === name.toLowerCase()) {
            select.selectedIndex = i;
            exists = true;
            break;
        }
    }
    
    if (!exists) {
        const newOpt = document.createElement('option');
        newOpt.value = name;
        newOpt.text = name;
        select.add(newOpt);
        select.selectedIndex = select.options.length - 1;
    }
    
    select.dispatchEvent(new Event('change'));
};

// INITIAL SETUP RUNS
if (STATE.customerLocation) {
    addAndSelectUserLocation(STATE.customerLocation);
}
switchRole(STATE.currentRole || 'customer');
updateCartStats();
Logger.log('Interactive Multi-Vendor FarmFresh Simulator re-initialized.', 'system');
Logger.log('Ready to test. Switch roles above to inspect screens.', 'system');

// SIMULATED CUSTOMER CALLING MODULE
window.startCallSimulation = function(name, phone) {
    const modal = document.getElementById('calling-modal');
    const nameEl = document.getElementById('calling-customer-name');
    const phoneEl = document.getElementById('calling-customer-phone');
    if (modal && nameEl && phoneEl) {
        nameEl.innerText = name;
        phoneEl.innerText = phone;
        modal.style.display = 'flex';
    }
};

window.closeCallSimulation = function() {
    const modal = document.getElementById('calling-modal');
    if (modal) modal.style.display = 'none';
};

window.farmerRejectOrder = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'rejected';
    Logger.log(`Farmer rejected order #${orderId}. Payment will be refunded to customer.`, 'farmer');
    
    const farmer = STATE.merchants[0];
    if (farmer.activeOrders > 0) farmer.activeOrders -= 1;
    
    updateFarmerStats();
    renderFarmerOrders();
    saveStateToStorage();
    
    Notification.show('Order Rejected', `Farmer Organico Farm declined order #${orderId}. Refund initiated.`);
    syncTrackingUI();
};

window.switchFarmerTab = function(screenId) {
    switchScreen(screenId);
    updateActiveBottomTab(screenId);
};
