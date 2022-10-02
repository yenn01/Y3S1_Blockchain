import { writable } from "svelte/store";
import { localStore } from './localStore.js'
const defaultVal = 'wBitcoin'

export const defaultRecent = localStore('defaultRecent',defaultVal);