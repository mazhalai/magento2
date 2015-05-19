/**
 * Copyright © 2015 Magento. All rights reserved.
 * See COPYING.txt for license details.
 */
/*jshint browser:true*/
/*global define,alert*/
define(
    [
        "jquery",
        'Magento_Ui/js/form/form',
        'ko',
        'Magento_Customer/js/model/customer',
        '../action/select-billing-address',
        'Magento_Checkout/js/model/step-navigator',
        '../model/quote',
        '../model/addresslist',
        '../action/check-email-availability',
        'mage/validation'
    ],
    function ($, Component, ko, customer, selectBillingAddress, navigator, quote, addressList, checkEmailAvailability) {
        "use strict";
        var stepName = 'billingAddress';
        var newAddressSelected = ko.observable(false);
        var billingFormSelector = '#co-billing-form';

        return Component.extend({
            defaults: {
                template: 'Magento_Checkout/billing-address'
            },
            initObservable: function () {
                this._super().observe('useForShipping');
                return this;
            },
            stepClassAttributes: function() {
                return navigator.getStepClassAttributes(stepName);
            },
            stepNumber: navigator.getStepNumber(stepName),
            billingAddresses: customer.getBillingAddressList(),
            selectedBillingAddressId: addressList.getAddresses()[0].customerAddressId,
            isVisible: navigator.isStepVisible(stepName),
            useForShipping: "1",
            quoteIsVirtual: quote.isVirtual(),
            isEmailCheckComplete: $.Deferred(),
            billingAddressesOptionsText: function(item) {
                return item.getAddressInline();
            },
            checkUseForShipping: function(useForShipping) {
                var additionalData = {};
                if (useForShipping() instanceof Object) {
                    additionalData = useForShipping().getAdditionalData();
                    useForShipping('1');
                }
                return additionalData;
            },
            submitBillingAddress: function() {
                if (this.selectedBillingAddressId) {
                    var additionalData = this.checkUseForShipping(this.useForShipping);
                    selectBillingAddress(
                        addressList.getAddressById(this.selectedBillingAddressId),
                        this.useForShipping,
                        additionalData
                    );
                } else {
                    var that = this;
                    this.validate();
                    $.when(this.isEmailCheckComplete).done( function() {
                        if (!that.source.get('params.invalid')) {
                            var addressData = that.source.get('billingAddress');
                            var additionalData = that.checkUseForShipping(that.useForShipping);
                            /**
                             * All the the input fields that are not a part of the address but need to be submitted
                             * in the same request must have data-scope attribute set
                             */
                            var additionalFields = $('input[data-scope="additionalAddressData"]').serializeArray();
                            additionalFields.forEach(function (field) {
                                additionalData[field.name] = field.value;
                            });
                            if (quote.getCheckoutMethod()() && !customer.isLoggedIn()()) {
                                addressData.email = that.source.get('customerDetails.email');
                            }
                            if($(billingFormSelector).validation() && $(billingFormSelector).validation('isValid')) {
                                selectBillingAddress(addressData, that.useForShipping, additionalData);
                            }
                        }
                    }).fail( function() {
                        alert(
                            "There is already a registered customer using this email address. " +
                            "Please log in using this email address or enter a different email address " +
                            "to register your account."
                        );
                    });
                }
            },
            navigateToCurrentStep: function() {
                if (!navigator.isStepVisible(stepName)()) {
                    navigator.goToStep(stepName);
                }
            },
            isNewAddressSelected: function() {
                if (!this.customerAddressCount) {
                    return true;
                }
                return newAddressSelected();
            },
            onAddressChange: function (value) {
                if (value === null) {
                    newAddressSelected(true);
                } else {
                    newAddressSelected(false);
                }
            },
            validate: function() {
                var fields = $(billingFormSelector).find('input, select');

                this.source.set('params.invalid', false);
                fields.trigger('change');
                this.source.trigger('billingAddress.data.validate');
                this.validateAdditionalAddressFields();
                this.isEmailCheckComplete.resolve();
            },
            validateAdditionalAddressFields: function() {
                $(billingFormSelector).validation();
                $(billingFormSelector + ' input[data-scope="additionalAddressData"]').each(function(key, item) {
                    $(item).valid();
                });
            },
            isCustomerLoggedIn: customer.isLoggedIn(),
            customerAddressCount: window.checkoutConfig.customerAddressCount,
            hideExtraFields: function() {
                if (!quote.getCheckoutMethod()() && customer.isLoggedIn()()) {
                    $('[name="customerDetails.email"]').hide();
                }
            }
        });
    }
);