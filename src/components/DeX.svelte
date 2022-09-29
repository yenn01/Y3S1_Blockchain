<script>
    import { ethers } from "ethers";
    import abi from '../../build/contracts/DeX.json';

    //Used to create dispatch events catched by parent components
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract('0x4460c452A40a3F33bbfb24dF65134bBBc95B38f7', abi.abi, provider);
    let allPools

    function setSigner() {

    }

    //Read Functions
    export function getAllPools() {
        contract.listAllPool().then((res)=> {
            console.log(res)
            dispatch('s_getAllPools',res)
        })
    }

    export function getAllActivePools() {
        contract.listAllValidPool().then((res)=> {
            console.log(res)
            dispatch('s_getAllActivePools',res)
        })
    }

    export function getPool(name) {
        contract.getPool(name).then((res) => {
            console.log(res)
            dispatch('s_getPool',res)
        })
    }
    

</script>