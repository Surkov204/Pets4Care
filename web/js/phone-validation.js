/**
 * Phone Number Validation for Boarding Modal
 * Xử lý validation số điện thoại trong popup modal
 */

// Phone validation functions
function validatePhoneNumber(phone) {
    if (!phone || phone.trim() === '') {
        return false;
    }
    
    // Remove all non-digit characters
    const cleanPhone = phone.replace(/\D/g, '');
    
    // Check if phone has 10 or 11 digits
    return cleanPhone.length === 10 || cleanPhone.length === 11;
}

function formatPhoneNumber(phone) {
    if (!phone) return '';
    
    // Remove all non-digit characters
    const cleanPhone = phone.replace(/\D/g, '');
    
    // Format based on length
    if (cleanPhone.length === 10) {
        return cleanPhone.replace(/(\d{4})(\d{3})(\d{3})/, '$1 $2 $3');
    } else if (cleanPhone.length === 11) {
        return cleanPhone.replace(/(\d{4})(\d{3})(\d{4})/, '$1 $2 $3');
    }
    
    return cleanPhone;
}

function validatePhoneInput(input) {
    const phone = input.value;
    const isValid = validatePhoneNumber(phone);
    
    // Remove validation classes
    input.classList.remove('border-red-500', 'border-green-500');
    
    if (phone.trim() === '') {
        // Empty input - neutral state
        input.classList.add('border-gray-300');
        return true;
    }
    
    if (isValid) {
        input.classList.add('border-green-500');
        input.setCustomValidity('');
        return true;
    } else {
        input.classList.add('border-red-500');
        input.setCustomValidity('Số điện thoại phải có 10 hoặc 11 chữ số');
        return false;
    }
}

function formatPhoneInput(input) {
    const formatted = formatPhoneNumber(input.value);
    if (formatted !== input.value) {
        input.value = formatted;
    }
}

// Initialize phone validation for boarding modal
function initializePhoneValidation() {
    // Wait for modal to be loaded
    setTimeout(() => {
        const emergencyPhone1 = document.getElementById('emergencyPhone1');
        const emergencyPhone2 = document.getElementById('emergencyPhone2');
        
        if (emergencyPhone1) {
            emergencyPhone1.addEventListener('input', function() {
                formatPhoneInput(this);
                validatePhoneInput(this);
            });
            
            emergencyPhone1.addEventListener('blur', function() {
                validatePhoneInput(this);
            });
        }
        
        if (emergencyPhone2) {
            emergencyPhone2.addEventListener('input', function() {
                formatPhoneInput(this);
                validatePhoneInput(this);
            });
            
            emergencyPhone2.addEventListener('blur', function() {
                validatePhoneInput(this);
            });
        }
    }, 100);
}

// Validate all phone numbers before form submission
function validateAllPhones() {
    const emergencyPhone1 = document.getElementById('emergencyPhone1');
    const emergencyPhone2 = document.getElementById('emergencyPhone2');
    
    let isValid = true;
    
    // Validate emergency phone 1 (required)
    if (emergencyPhone1) {
        if (!validatePhoneInput(emergencyPhone1)) {
            isValid = false;
        }
    }
    
    // Validate emergency phone 2 (optional)
    if (emergencyPhone2 && emergencyPhone2.value.trim() !== '') {
        if (!validatePhoneInput(emergencyPhone2)) {
            isValid = false;
        }
    }
    
    return isValid;
}

// Enhanced form submission with phone validation
function submitBoardingForm() {
    if (!validateAllPhones()) {
        alert('Vui lòng kiểm tra lại số điện thoại. Số điện thoại phải có 10 hoặc 11 chữ số.');
        return false;
    }
    
    // Additional form validation
    const form = document.getElementById('boardingForm');
    if (form) {
        form.submit();
    }
}

// Auto-format phone numbers on page load
document.addEventListener('DOMContentLoaded', function() {
    initializePhoneValidation();
});

// Re-initialize when modal is opened
function openBoardingModal(roomId, roomType, pricePerDay) {
    // Your existing modal opening code here
    // ...
    
    // Re-initialize phone validation
    setTimeout(() => {
        initializePhoneValidation();
    }, 200);
}