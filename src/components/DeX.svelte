<script>
    import { ethers } from "ethers";
    import abi from '../../build/contracts/DeX.json';

    //Used to create dispatch events catched by parent components
    import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    const contractAddr = '0x4460c452A40a3F33bbfb24dF65134bBBc95B38f7'

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


    //Write Functions
    export function addPool(name,val,against) {
        getSigner()
        contract.addPool(name,val,against).then((res)=> {
            dispatch('s_addPool',res)
        })
    }

    export function addAmt(name,val,against) {
        getSigner()
        contract.addAmt(name,val,against).then((res)=> {
            dispatch('s_addAmt',res)
        })
    }

    export function editPoolDetail(name,newname,val,against,status) {
        getSigner()
        contract.addAmt(name,val,against).then((res)=> {
            dispatch('s_addAmt',res)
        })
    }

    export function exchangeBuy(deposit,amt,target) {
        getSigner()
        contract.exchangeBuy(deposit,amt,target).then((res)=> {
            dispatch('s_exchangeBuy',res)
        })
    }
    
    export function exchangeSell(deposit,amt,target) {
        getSigner()
        contract.exchangeSell(deposit,amt,target).then((res) => {
            dispatch('s_exchangeSell',res)
        })
    }

    export let dashboard;

    if( dashboard == true) {
        getAllActivePools()

    }



    function formatTokenListResponse(response) {
        let allActive = [];
        response.forEach((item,i) => {

            const obj = {}
            obj['name'] = item[0]
            obj['coinAmount'] =  item[1].toNumber()
            obj['tokenAmount'] = item[2].toNumber()
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