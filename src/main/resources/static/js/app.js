function setupDynamicSearch() {
    var forms = document.querySelectorAll('form[data-dynamic-search="true"]');
    forms.forEach(function (form) {
        var input = form.querySelector('input[name="q"]');
        if (!input) {
            return;
        }
        var timer = null;
        input.addEventListener('input', function () {
            if (timer) {
                clearTimeout(timer);
            }
            timer = setTimeout(function () {
                form.submit();
            }, 300);
        });
    });
}

function setupDonationTypeBehavior() {
    var form = document.querySelector('form[data-donation-form="true"]');
    if (!form) {
        return;
    }

    var typeSelect = form.querySelector('select[name="tipo_donacion"]');
    var amountWrap = form.querySelector('[data-monto-wrap="true"]');
    var amountInput = form.querySelector('input[name="monto"]');
    if (!typeSelect || !amountWrap || !amountInput) {
        return;
    }

    var sync = function () {
        var type = (typeSelect.value || '').toUpperCase();
        var isMonetary = type === 'MONETARIA';
        amountWrap.style.display = isMonetary ? '' : 'none';
        amountInput.required = isMonetary;
        if (!isMonetary) {
            amountInput.value = '';
        }
    };

    typeSelect.addEventListener('change', sync);
    sync();
}

function setupEntregaResponsableFilter() {
    var form = document.querySelector('form[data-entrega-form="true"]');
    if (!form) {
        return;
    }

    var comunidadSelect = form.querySelector('select[data-comunidad-select="true"]');
    var responsableSelect = form.querySelector('select[data-responsable-select="true"]');
    if (!comunidadSelect || !responsableSelect) {
        return;
    }

    var options = Array.prototype.slice.call(responsableSelect.querySelectorAll('option'));
    var sync = function () {
        var comunidadId = comunidadSelect.value || '';
        var selectedStillValid = false;
        options.forEach(function (opt, index) {
            if (index === 0) {
                opt.hidden = false;
                return;
            }
            var optComunidad = opt.getAttribute('data-comunidad-id') || '';
            var visible = comunidadId !== '' && optComunidad === comunidadId;
            opt.hidden = !visible;
            if (visible && opt.value === responsableSelect.value) {
                selectedStillValid = true;
            }
        });
        if (!selectedStillValid && responsableSelect.value !== '') {
            responsableSelect.value = '';
        }
    };

    comunidadSelect.addEventListener('change', sync);
    sync();
}

document.addEventListener('DOMContentLoaded', function () {
    setupDynamicSearch();
    setupDonationTypeBehavior();
    setupEntregaResponsableFilter();
});
