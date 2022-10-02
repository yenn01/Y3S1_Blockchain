import { writable } from "svelte/store";
import { localStore } from './localStore.js'
const defaultVal = 'Bitcoin'

export const defaultRecent = localStore('defaultRecent',defaultVal);