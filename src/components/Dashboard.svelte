<script>
    import { forEach } from '@metamask/jazzicon/colors';
    import { fade } from 'svelte/transition';
    import DeX from './DeX.svelte';
    import { ethers } from "ethers";
    import anime from 'animejs/lib/anime.es.js';
    import { svg_element } from 'svelte/internal';
    import { chart } from "svelte-apexcharts";

    let dex;
    let activePoolNum;
    $: totalSupply = 0
    $: blockNum = 0;
    export let show;

    let tVal = []
    let cVal = []
    let price = []
    let label = []
    let coins = []
    let data = {}

    const loadGraph = (eventMsg) => {
        const res = eventMsg.detail;
        console.log("loading graph...")
        tVal = []
        cVal = []
        label = []
        price = []
        coins = []
        res.forEach((item,index)=> {
            tVal.push(item.tVal.value.toNumber())
            cVal.push(item.cVal.value.toNumber())
            label.push(' ')
            let calculate = item.cVal.value.toNumber()/item.tVal.value.toNumber()
            price.push(calculate.toFixed(3))
            coins.push(item.name+"/yToken")
        })
        console.log(tVal)
        console.log(cVal)


        data = {
            chart: {
                type: 'area',
                stacked : false
            },
            dataLabels: {
                enabled: false
            },
            markers: {
                size: 5,
            },

            stroke: {
                curve: 'straight'
            },
            colors: ["#ea86a7", "#8cc9dc"],
        
            series: [
                    {
                        name:'Token Amount',
                        data: price,
                    },
            ],
            yaxis: [
                {
                title: {
                    text: "Token Amount",
                    style: {
                        color: '#ea86a7'
                    }
                },
                labels: {
                    style: {
                    colors: "#ea86a7"
                    }
                },
                },
                
            ],
        };
        show = true;
    }


    const loadActivePools = (eventMsg) => {

            console.log(eventMsg.detail)
            eventMsg.detail.forEach((item,index)=> {
                    totalSupply += item.tokenAmount;
            })
            activePoolNum = eventMsg.detail.length;
            anime({
                    targets: '#totalSupply',
                    innerHTML: [0,totalSupply],
                    easing: 'easeOutExpo',
                    round:1,
                    duration:3000,            
            })
            getBlock()
    //     console.log(allActive)

    //     // const keys = eventMsg.detail.slice(4,7)
    //     // let parsed = JSON.parse(JSON.stringify())
    //     // console.log(parsed)
    //     // 4-7
    //     show = true;
    }

    const getBlock = async () => {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        blockNum = await provider.getBlockNumber();
        console.log(blockNum)
        anime({
            targets: '#latestBlock',
            innerHTML: [0,blockNum],
            easing: 'easeOutExpo',
            round:1,
            duration:3000,            
        })
        //when new block is mined
        provider.on('block', async () => {
            console.log("New Block")
            blockNum = await provider.getBlockNumber();
           
            anime({
                targets: '#latestBlock',
                innerHTML: [0,blockNum],
                easing: 'easeOutExpo',
                round:1,
                duration:2000,            
            
            })
        })

    }

   

    function  addPoolTest() {
        //dex.addPool('Aurora',15000,20000)
        dex.exchangeBuy('Pax Gold',10,'Bitcoin')
    }

</script>
<DeX bind:this={dex} dashboard={true} on:s_getAllActivePools={loadActivePools} 
                                        on:s_addPool={loadActivePools} 
                                        on:s_getLast10ValChanges={loadGraph}></DeX>
<div class="dashboard-container">
    <div class="right-container">
        <div class="bubble">
            <h1 id="totalSupply">{totalSupply}</h1>
            <p>Total Supply</p>
            
        </div>
        <div class="bubble">
            <h1 id="activePoolNum">{activePoolNum}</h1>
            <p>Number of Active Pools</p>
            
        </div>
        <div class="bubble">
            <h1 id="latestBlock">{blockNum}</h1>
            <p>Latest Block</p>
            
        </div>
    </div>
    <div class="left-container">
        <div class="left-top-container">
            <h2>Recent Price Changes of</h2>
            <select></select>
        </div>
        <div class="graph-container">
            {#if show }
               <div use:chart={data}/>
            {/if}
        </div>
    </div>
    <div class="bottom-container">
        <div>some text</div>
    </div>
</div>
<button on:click={() => {dex.getValChanges()}}>Get Filters</button>
<button on:click={() => {dex.exchangeBuy('Bitcoin',5,'Ether')}}>Exchange</button>





<style>
    .bubble {
        padding:1rem;
    }



    #latestBlock{
        color:var(--theme-color-third)
    }

    p {
        margin:0 !important;
        font-family:'Iosevka Web', monospace;
        font-size: 1rem;
    }
    h1 {
        margin:0;
        font-family:'Iosevka Web', monospace;
        color: var(--theme-color-main);
    }

    .dashboard-container {
        display:flex;
        flex-wrap: wrap;
        flex-direction: row-reverse;
        justify-content: space-around;
        margin:1rem 0
        ;
    }

    .dashboard-container > div {
        margin: 1rem;
    }

    .right-container{
        display:flex;
        flex-direction: column;
        flex-grow:2;
        flex-shrink: 0;
        flex-basis: 200px;
    }

    .right-container div {
        background-color: var(--theme-color-darker-bg);
        border-radius: 10px;
    }

    .right-container div ~ div{
        margin: 1rem 0 ;
    }

    .left-container{
        display:flex;
        flex-direction: column;
        flex-grow:3;
        background-color: var(--theme-color-darker-bg);
        border-radius: 10px;
        min-height: 40vh;
        flex-shrink: 0;
        flex-basis: 400px;
    }

    .bottom-container {
        flex-basis:100%;
    }
    
</style>