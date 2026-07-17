const http = require('http');

async function testApi() {
  console.log('--- Starting API Tests ---');
  try {
    // 1. Admin Login
    console.log('Testing Admin Login...');
    const loginRes = await fetch('http://localhost:3000/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: 'admin@farmfresh.com', password: 'Admin@123' }) 
    });
    const loginData = await loginRes.json();
    if (!loginRes.ok) {
        console.error('Admin Login Failed:', loginData);
        return;
    } else {
        console.log('Admin Login Successful!');
        global.token = loginData.data.accessToken;
    }

    const headers = {
      'Authorization': `Bearer ${global.token}`,
      'Content-Type': 'application/json'
    };

    // 2. Fetch Orders
    console.log('\nTesting Order Management...');
    const ordersRes = await fetch('http://localhost:3000/api/v1/admin/orders', { headers });
    if (ordersRes.ok) {
      const orders = await ordersRes.json();
      console.log(`Successfully fetched orders. Count: ${orders.data?.items?.length || 0}`);
    } else {
      console.error('Failed to fetch orders:', await ordersRes.text());
    }

    // 3. Fetch Products for Approval
    console.log('\nTesting Product Approval...');
    const productsRes = await fetch('http://localhost:3000/api/v1/admin/products?status=PENDING_APPROVAL', { headers });
    if (productsRes.ok) {
      const products = await productsRes.json();
      console.log(`Successfully fetched pending products. Count: ${products.data?.items?.length || 0}`);
    } else {
      console.error('Failed to fetch pending products:', await productsRes.text());
    }

    // 4. Fetch Analytics/Reporting
    console.log('\nTesting Reporting...');
    const analyticsRes = await fetch('http://localhost:3000/api/v1/admin/dashboard', { headers });
    if (analyticsRes.ok) {
      console.log('Successfully fetched dashboard data.');
    } else {
      console.error('Failed to fetch analytics:', await analyticsRes.text());
    }
    
    console.log('\n--- API Tests Completed ---');
  } catch (error) {
    console.error('Test Error:', error);
  }
}

testApi();
