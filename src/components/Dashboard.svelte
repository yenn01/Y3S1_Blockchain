<script>
    import { forEach } from '@metamask/jazzicon/colors';
    import { fade } from 'svelte/transition';
    import { ethers } from "ethers";
    import anime from 'animejs/lib/anime.es.js';
    import { svg_element } from 'svelte/internal';
    import { chart } from "svelte-apexcharts";
    import {defaultRecent} from '../stores/defaultRecent.js'
    import DeX from './DeX.svelte';

    let dex;
    let activePoolNum;
    $: totalSupply = 0
    $: blockNum = 0;
    export let show;

    let tVal = []
    let cVal = []
    let price = []
    let label = []
    $: coins = []
    let data = {}
    let select
    let counter = 0
    let selected
    let defaultToken

    const loadGraph = (eventMsg) => {
        const res = eventMsg.detail;
        console.log("loading graph...")
        tVal = []
        cVal = []
        label = []
        price = []

        res.forEach((item,index)=> {
            // tVal.push(item.tVal.value.toNumber())
            // cVal.push(item.cVal.value.toNumber())
            label.push(' ')
            let calculate = item.tVal.value.toNumber()/item.cVal.value.toNumber()
            console.log(calculate.toString())
            price.push(calculate)
            console.log()
           
        })
        console.log(coins)


        data = {
            chart: {
                type: 'area',
                stacked : false,
                toolbar: {
                    show:false
                }
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
                    tickAmount: 4,
                    labels: {
                        style:{
                            colors: ['#ea86a7']
                        },
                    }

                },
                
            ],
            xaxis: 
                {
                    title: {
                        text: "Last 10 Pool Transactions",
                        style: {
                            color: '#8cc9dc'
                        }
                    },
                    labels: {
                        style:{
                            colors: '#8cc9dc'
                        }
                    }

                },
                
            
        };
        show = true;
    }


    const loadActivePools = (eventMsg) => {
            coins = []
            console.log(eventMsg.detail)
            //select.value = eventMsg.detail[0].name+" / yToken"
            
            eventMsg.detail.forEach((item,index)=> {
                    totalSupply += item.tokenAmount / Math.pow(10,9);
                    
                    coins.push({id:counter,name:item.name+" / yToken",cVal:item.coinAmount.toNumber()/Math.pow(10,9),tVal:item.tokenAmount.toNumber()/Math.pow(10,9)})
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
            console.log("name")
            console.log(coins)
            yTokenValue()
    //     console.log(allActive)

    //     // const keys = eventMsg.detail.slice(4,7)
    //     // let parsed = JSON.parse(JSON.stringify())
    //     // console.log(parsed)
    //     // 4-7
         show = true;
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

    let ethPrice = 0;
    let yVolume = 0;
    const yTokenValue = async () => {
        const url = 'https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd'
        const response = await fetch(url).then(res => res.json()).then((passed) => {
           ethPrice = passed.ethereum.usd;
           yVolume = totalSupply * ethPrice;
        })
        let element = document.querySelector('#yVolume');

        anime({
                targets: element,
                innerHTML: [0,yVolume],
                easing: 'easeOutExpo',
                round:1,
                duration:2000,            
                update: function(a) {
                    const value = a.animations[0].currentValue;
                    let nf = new Intl.NumberFormat('en-US');
                    const formattedNumber= nf.format(value);
                    element.innerHTML = formattedNumber;
                }
            })
    }

   

    function  addPoolTest() {
        //dex.addPool('Aurora',15000,20000)
        dex.exchangeBuy('BNB',10,'wBitcoin')
    }

    

</script>
<DeX bind:this={dex} dashboard={true} {defaultToken} on:s_getAllActivePools={loadActivePools} 
                                        on:s_addPool={loadActivePools} 
                                        on:s_getLast10ValChanges={loadGraph}></DeX>
<div class="dashboard-container">
    <div class="right-container">
        <div class="bubble">
            <h1 id="totalSupply">{totalSupply}</h1>
            <p>Total yTokens in Pool</p>
            
        </div>
        <div class="bubble">
            <h1><span id="yVolume">{yVolume}</span> <span class="dollar-sign">$</span></h1>
            <p>yToken Total Volume Price</p>
            
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
            <h2>Recent Price Changes of  </h2>
            {#if coins.length > 0}
            <select bind:value={selected} on:change={() => {
                const regexp = /(.+) \/ yToken/g;
                let match = regexp.exec(selected.name)
                dex.getLast10ValChanges(match[1])
            }}>
                {#each coins as coin}
                    <option value={coin}>
                            {coin.name}
                    </option>
                {/each}
            </select>
            {/if}
        </div>
        <div class="graph-container">
            {#if show }
               <div use:chart={data}/>
            {/if}
        </div>
    </div>
    {#if show === true}
    <div class="bottom-container">
        <div class="row-pool row-title">
            <div class="">Pair</div>
            <div class="">Number of Coins</div>
            <div class="">Number of Tokens</div>
        </div>
        <hr>
        {#each coins as coin (coin.name)}

        <div class="row-pool">
            <div class="">{coin.name}</div>
            <div class="">{coin.cVal.toFixed(5)}</div>
            <div class="">{coin.tVal.toFixed(5)}</div>
        </div>
        {/each}
    </div>
    {/if}
</div>


<!-- <button on:click={() => {dex.getValChanges()}}>Get Filters</button>
<button on:click={() => {dex.exchangeBuy('wBitcoin',20,'BNB')}}>Exchange</button>
<button on:click={() => {dex.deposit(5)}}>Deposit</button> -->





<style>

    .row-pool {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        grid-template-rows: 1fr;
        font-family: 'Iosevka Web', monospace;
    }

    .row-title {
        font-weight: 500;
        font-size: 1.3rem;
    }

    .dollar-sign {
        font-size: 3rem;
        color: var(--text-color)
    }

    .bubble {
        padding:1rem;
    }

    .left-top-container {
        display:flex;
        justify-content: space-between;
        margin-bottom: 1rem;
    }

    .bottom-container {
        background-color: var(--theme-color-darker-bg);
        padding: 1rem;
    }


    #latestBlock{
        color:var(--theme-color-third)
    }

    #yVolume {
        color:var(--theme-color-second)
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
        margin:1rem 0;
        width:100%;
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

    .right-container div {
        margin-bottom: 1rem ;
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
        padding:2rem;
    }

    .bottom-container {
        flex-basis:100%;
    }
    
</style>