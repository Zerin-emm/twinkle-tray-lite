"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
const SUPPORTED_PLATFORMS = ['win32'];
let addon;
if (SUPPORTED_PLATFORMS.includes(process.platform)) {
    addon = require('../build/Release/PaymoActiveWindow.node'); // eslint-disable-line import/no-dynamic-require
}
else {
    throw new Error(`Unsupported platform. The supported platforms are: ${SUPPORTED_PLATFORMS.join(',')}`);
}
const encodeWindowInfo = (info) => {
    return Object.assign({ title: info.title, application: info.application, path: info.path, pid: info.pid, icon: info.icon }, {
        windows: {
            isUWPApp: info['windows.isUWPApp'] || false,
            uwpPackage: info['windows.uwpPackage'] || ''
        }
    });
};
const ActiveWindow = {
    getActiveWindow: () => {
        if (!addon) {
            throw new Error('Failed to load native addon');
        }
        const info = addon.getActiveWindow();
        return encodeWindowInfo(info);
    },
    subscribe: (callback) => {
        if (!addon) {
            throw new Error('Failed to load native addon');
        }
        const watchId = addon.subscribe(nativeWindowInfo => {
            callback(!nativeWindowInfo ? null : encodeWindowInfo(nativeWindowInfo));
        });
        return watchId;
    },
    unsubscribe: (watchId) => {
        if (!addon) {
            throw new Error('Failed to load native addon');
        }
        if (watchId < 0) {
            throw new Error('Watch ID must be a positive number');
        }
        addon.unsubscribe(watchId);
    },
    initialize: () => {
        if (!addon) {
            throw new Error('Failed to load native addon');
        }
        if (addon.initialize) {
            addon.initialize();
        }
    },
    requestPermissions: () => {
        if (!addon) {
            throw new Error('Failed to load native addon');
        }
        if (addon.requestPermissions) {
            return addon.requestPermissions();
        }
        return true;
    }
};
__exportStar(require("./types"), exports);
exports.default = ActiveWindow;
