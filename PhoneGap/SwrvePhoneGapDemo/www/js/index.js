/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    onDeviceReady: function() {
        var parentElement = document.getElementById('swrve-panel');
        parentElement.setAttribute('style','display:block;');

        parentElement.querySelector('.swrve-event-button').addEventListener('click', function() {
            window.plugins.swrve.event("helo.from.phonegap", [], function() {
                window.plugins.toast.showShortTop("Event queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: event not queued");
            });
        });

        parentElement.querySelector('.swrve-event-payload-button').addEventListener('click', function() {
            window.plugins.swrve.event("helo.from.phonegap", {"test":"payload"}, function() {
                window.plugins.toast.showShortTop("Event with payload queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: event with payload not queued");
            });
        });
        parentElement.querySelector('.swrve-update-button').addEventListener('click', function() {
            window.plugins.swrve.userUpdate({"phonegap": "TRUE"}, function() {
                window.plugins.toast.showShortTop("User update queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: user update not queued");
            });
        });
        parentElement.querySelector('.swrve-currency-given').addEventListener('click', function() {
            window.plugins.swrve.currencyGiven("gold", 20, function() {
                window.plugins.toast.showShortTop("Currency given queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: currency given not queued");
            });
        });
        parentElement.querySelector('.swrve-purchase').addEventListener('click', function() {
            window.plugins.swrve.purchase("your.item", "gold", 2, 15, function() {
                window.plugins.toast.showShortTop("Purchase queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: purchase not queued");
            });
        });
        
        if (window.plugins.swrve.android) {
            parentElement.querySelector('.swrve-iap').addEventListener('click', function() {
                window.plugins.swrve.iap(2, "your.item", 2.99, "USD", function() {
                    window.plugins.toast.showShortTop("IAP queued");
                }, function () {
                    window.plugins.toast.showShortTop("Error: IAP not queued");
                });
            });
        } else {
            parentElement.querySelector('.swrve-iap').setAttribute('style','display:none;');
        }
        parentElement.querySelector('.swrve-send-events-button').addEventListener('click', function() {
            window.plugins.swrve.sendEvents(function() {
                window.plugins.toast.showShortTop("Event queue sent to Swrve");
            }, function () {
                window.plugins.toast.showShortTop("Error: event queue not sent");
            });
        });
        parentElement.querySelector('.swrve-resources-button').addEventListener('click', function() {
            window.plugins.swrve.getUserResources(function(resources) {
                // JSON object containing the resources
                window.alert(resources);
            }, function () {
                window.plugins.toast.showShortTop("Error: could not get resources");
            });
        });
        parentElement.querySelector('.swrve-resources-diff-button').addEventListener('click', function() {
            window.plugins.swrve.getUserResourcesDiff(function(resourcesDiff) {
                // JSON object containing the resources
                window.alert(resourcesDiff);
            }, function () {
                window.plugins.toast.showShortTop("Error: could not get resources diff");
            });
        });
    }
};
