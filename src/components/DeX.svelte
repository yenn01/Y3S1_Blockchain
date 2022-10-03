<script>
    import { ethers, utils } from "ethers";
    import abi from '../../build/contracts/DeX.json';

    //Used to create dispatch events catched by parent components
    import { createEventDispatcher } from 'svelte';
    import {defaultRecent} from '../stores/defaultRecent'
    import { accountStore } from '../stores/accountStore.js'
    import { notifications } from "../stores/notifications";

    const dispatch = createEventDispatcher();

    const contractAddr = '0x017566f4034cD6477a804ff7B08897b1F8deAE68'

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    let contract = new ethers.Contract(contractAddr, abi.abi, provider);

    let allPools

    function getSigner() {
        const signer = provider.getSigner()
        contract = new ethers.Contract(contractAddr, abi.abi, signer );
    }

    function getProvider() {
        contract = new ethers.Contract(contractAddr, abi.abi, provider);
    }

    //Read Functions
    export function getEther() {
        contract.getEther().then((res)=> {
            console.log(res)
            dispatch('s_getEther',res)
        })
    }

    export function getBalanceOf(address) {
        contract.balanceOf(address).then((res)=> {
            //console.log(res)
            dispatch('s_getBalanceOf',res)
        })
    }



    export function getAllPools() {
        contract.listAllPool().then((res)=> {
            console.log(res)
            dispatch('s_getAllPools',formatTokenListResponse(res))
        })
    }

    export function getAllActivePools() {
        contract.listAllValidPool().then((res)=> {
            console.log(res)
            dispatch('s_getAllActivePools',formatTokenListResponse(res))
        })
    }

    export function getPool(name) {
        contract.getPool(name).then((res) => {
            console.log(res)
            dispatch('s_getPool',res)
        })
    }

    export const getOwner = async () => {
        const flt = contract.filters.OwnerSet(null,contractAddr)
        const log = await getEthersLog(contract, flt)  
        console.log(log)
    }
    export const getValChanges = async () => {
        const flt = contract.filters.PoolValue('Ether')
        console.log(flt)
        const log = await getEthersLog(contract, flt)  
        console.log(log)
    }

    export const getLast10ValChanges = async (coinName) => {
        console.log(coinName)
        const flt = contract.filters.PoolValue(coinName)
        const log = await getEthersLog(contract, flt)  
        const last = log.slice(Math.max(log.length - 10, 0))
        console.log(last)
        dispatch('s_getLast10ValChanges',last)
    }


    //Write Functions
    export function addPool(name,val,against) {
        getSigner()
        contract.addPool(name,val*Math.pow(10,9),against*Math.pow(10,9)).then((res)=> {
            dispatch('s_addPool',res)
        }).catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
    }

    export const getAddPoolGas = async (name,val,against) => {
        const gasFee = await provider.getGasPrice();
        await contract.estimateGas.addPool(name,val*Math.pow(10,9),against*Math.pow(10,9)).then((res)=>{
            res = gasFee * res;
            dispatch('s_getAddPoolGas',res); //return in wei
        })
    }

    export function addAmt(name,val,against) {
        getSigner()
        contract.addAmt(name,val*Math.pow(10,9),against*Math.pow(10,9)).then((res)=> {
            dispatch('s_addAmt',res)
        })
        .catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
    }

    export const getAddAmtGas = async (name,val,against) => {
        const gasFee = await provider.getGasPrice();
        await contract.estimateGas.addAmt(name,val*Math.pow(10,9),against*Math.pow(10,9)).then((res)=>{
            res = gasFee * res;
            dispatch('s_getAddAmtGas',res); //return in wei
        })
    }

    export function editPoolDetail(name,newname,val,against,status) {
        getSigner()
        contract.addAmt(name,val,against).then((res)=> {
            dispatch('s_addAmt',res)
        })
        .catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
    }

    export function exchangeBuy(deposit,amt,target) {
        getSigner()
        contract.exchangeBuy(deposit,amt,target).then((res)=> {
            dispatch('s_exchangeBuy',res)
        })
        .catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
    }
    
    export function exchangeSell(deposit,amt,target) {
        getSigner()
        contract.exchangeSell(deposit,amt,target).then((res) => {
            dispatch('s_exchangeSell',res)
        })
        .catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
    }

    export function deposit(amt) {
        getSigner()
        let overrides = { value: utils.parseEther(amt.toString()) }

            contract.deposit(utils.parseEther(amt.toString()), overrides).then((res)=> {
                dispatch('s_deposit',res)
            })
        .catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
            
        
    }

    export const getExchangeBuyGas = async (deposit,amt,target) => {
        const gasFee = await provider.getGasPrice();
        await contract.estimateGas.exchangeBuy(deposit,amt,target).then((res)=>{
            res = gasFee * res;
            dispatch('s_getExchangeBuyGas',res); //return in wei
        })
    }

    export let swap;

    if(swap == true){
        getAllActivePools();
    }

    export function withdraw(amt) {
        getSigner()
        console.log(utils.parseEther(amt.toString()))

        contract.withdraw(utils.parseEther(amt.toString())).then((res)=> {
            dispatch('s_withdraw',res)
        })
        .catch((e) => {
            const regexp =/(.+)\(/g;
            let match = regexp.exec(e.message)
            notifications.danger(match[1].toUpperCase(),4000)
        }) 
    }

    

    const parseEtherjsLog = (parsed) => {
    let parsedEvent = {}
        for (let i = 0; i < parsed.args.length; i++) {
            const input = parsed.eventFragment.inputs[i]
            const arg = parsed.args[i]
            const newObj = {...input, ...{"value": arg}}
            parsedEvent[input["name"]] = newObj
        }
        return parsedEvent
    }

    export const getEthersLog = async (contract, filter) => {
        if (contract === undefined || filter === undefined ) return
        const events = await contract.queryFilter(filter)
        if (events.length === 0) return
        let parsedEvents = []
        for (let event of events) {
            const ethersParsed = contract.interface.parseLog(event)
            const customParsed = parseEtherjsLog(ethersParsed)
            parsedEvents.push(customParsed)
        }
        return parsedEvents
    }

    export let dashboard;
    export let defaultToken = 'Bitcoin';
    export let create;
    if( dashboard == true) {
        getAllActivePools()
        getLast10ValChanges($defaultRecent)
    }


    if(create == true) {
        getAllActivePools()
        getBalanceOf($accountStore)
    }




    function formatTokenListResponse(response) {
        let allActive = [];
        response.forEach((item,i) => {

            const obj = {}
            obj['name'] = item[0]
            obj['coinAmount'] =  item[1]
            obj['tokenAmount'] = item[2]
            obj['status'] = item[3]
        
            console.log(obj)

            //console.log(item)
            // const cut = item.slice(4,7)
            //const parsed = JSON.parse(JSON.stringify(item))
            allActive.push(obj)
            //console.log(parsed)
        })
        return allActive
    }

    

</script>