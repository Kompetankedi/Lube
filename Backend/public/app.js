// Lube Admin Dashboard Logic

document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    // Initial Data Load
    loadStats();
    loadVehicles();
});

function showSection(sectionId) {
    // Update navigation
    document.querySelectorAll('nav a').forEach(a => {
        a.classList.remove('active');
        if (a.getAttribute('onclick').includes(sectionId)) {
            a.classList.add('active');
        }
    });

    // Show section
    document.querySelectorAll('.content-section').forEach(s => {
        s.classList.remove('active');
    });
    document.getElementById(sectionId).classList.add('active');

    // Section specific loading
    if (sectionId === 'maintenance') {
        populateVehicleFilter();
    }
}

async function loadStats() {
    try {
        // Fetch all vehicles to count
        const response = await fetch('/api/vehicles');
        const vehicles = await response.json();
        
        document.getElementById('stat-vehicles').textContent = vehicles.length;
        
        // Mocking other stats for now as we don't have global stats endpoint yet
        document.getElementById('stat-users').textContent = "1"; // Admin only for now
        
        // Count total maintenance logs across all vehicles
        let totalLogs = 0;
        for (const v of vehicles) {
            const logRes = await fetch(`/api/maintenance/logs/${v.id}`);
            const logs = await logRes.json();
            totalLogs += logs.length;
        }
        document.getElementById('stat-maintenance').textContent = totalLogs;

    } catch (error) {
        console.error('Stats load failed:', error);
    }
}

async function loadVehicles() {
    try {
        const response = await fetch('/api/vehicles');
        const vehicles = await response.json();

        // Populate Recent Table
        const recentBody = document.querySelector('#recent-vehicles-table tbody');
        recentBody.innerHTML = '';
        
        vehicles.slice(0, 5).forEach(v => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>
                    <div style="font-weight: 600">${v.brand}</div>
                    <div style="font-size: 0.8rem; color: var(--text-muted)">${v.model}</div>
                </td>
                <td>${v.plate}</td>
                <td>${v.current_km.toLocaleString()} KM</td>
                <td><span class="badge success">Aktif</span></td>
            `;
            recentBody.appendChild(tr);
        });

        // Populate All Vehicles Table
        const allBody = document.querySelector('#all-vehicles-table tbody');
        allBody.innerHTML = '';
        vehicles.forEach(v => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>#${v.id}</td>
                <td>${v.brand}</td>
                <td>${v.model}</td>
                <td>${v.year}</td>
                <td>${v.plate}</td>
                <td>${v.current_km}</td>
                <td>
                    <button class="btn-text" onclick="deleteVehicle(${v.id})">Sil</button>
                </td>
            `;
            allBody.appendChild(tr);
        });

    } catch (error) {
        console.error('Vehicles load failed:', error);
    }
}

async function populateVehicleFilter() {
    const select = document.getElementById('vehicle-filter');
    const response = await fetch('/api/vehicles');
    const vehicles = await response.json();
    
    select.innerHTML = '<option value="">Araç Seçin...</option>';
    vehicles.forEach(v => {
        const opt = document.createElement('option');
        opt.value = v.id;
        opt.textContent = `${v.brand} ${v.model} (${v.plate})`;
        select.appendChild(opt);
    });
}

async function loadMaintenanceStatus() {
    const vehicleId = document.getElementById('vehicle-filter').value;
    if (!vehicleId) return;

    const grid = document.getElementById('maintenance-status-grid');
    grid.innerHTML = '<div class="loading">Yükleniyor...</div>';

    try {
        const response = await fetch(`/api/maintenance/status/${vehicleId}`);
        const status = await response.json();

        grid.innerHTML = '';
        status.forEach(s => {
            const card = document.createElement('div');
            card.className = 'maintenance-card';
            
            const badgeClass = s.remaining_km <= 0 ? 'danger' : (s.remaining_km < 2000 ? 'warning' : 'success');
            
            card.innerHTML = `
                <div class="m-header">
                    <h4>${s.name}</h4>
                    <span class="badge ${badgeClass}">${s.status_note}</span>
                </div>
                <div class="m-info">
                    <div><span>Periyot:</span> <span>${s.km_interval.toLocaleString()} KM</span></div>
                    <div><span>Son Bakım:</span> <span>${s.last_service_km ? s.last_service_km.toLocaleString() + ' KM' : 'Yok'}</span></div>
                    <div><span>Kalan:</span> <span>${s.remaining_km.toLocaleString()} KM</span></div>
                </div>
                ${s.warning_note ? `<div class="warning-box">${s.warning_note}</div>` : ''}
            `;
            grid.appendChild(card);
        });
    } catch (error) {
        grid.innerHTML = 'Hata oluştu.';
    }
}

async function deleteVehicle(id) {
    if (confirm('Aracı silmek istediğinize emin misiniz?')) {
        await fetch(`/api/vehicles/${id}`, { method: 'DELETE' });
        loadVehicles();
        loadStats();
    }
}
