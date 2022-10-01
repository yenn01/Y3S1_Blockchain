<script>
    import { forEach } from '@metamask/jazzicon/colors';
import DeX from './DeX.svelte';
import { ethers } from "ethers";
    import { svg_element } from 'svelte/internal';

let dex;

export let show;

 const loadActivePools = (eventMsg) => {

        console.log(eventMsg.detail)

//     console.log(allActive)

//     // const keys = eventMsg.detail.slice(4,7)
//     // let parsed = JSON.parse(JSON.stringify())
//     // console.log(parsed)
//     // 4-7
//     show = true;
 }

    function  addPoolTest() {
        //dex.addPool('Aurora',15000,20000)
        dex.exchangeBuy('Bitcoin','10','PAX Gold')
    }

</script>
<DeX bind:this={dex} dashboard={true} on:s_getAllActivePools={loadActivePools} on:s_addPool={loadActivePools}></DeX>
<button on:click={addPoolTest}>Add</button>
{#if show === true}


{/if}

<style>
    
</style>