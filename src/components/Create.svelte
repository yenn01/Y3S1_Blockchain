<script>
    import { accountStore } from '../stores/accountStore.js'
    import { notifications } from '../stores/notifications.js'
    import anime from 'animejs/lib/anime.es.js';
    import { ethers } from "ethers";
    import DeX from './DeX.svelte';

    $: accountBalance = 0;
    $: tokenBalance = 0;
    let dex
    let coinName = ''
    let exchange
    $: $accountStore, getBalance($accountStore)
    export const getBalance = async (address) => {
        console.log("Inner get")
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        let balance = await provider.getBalance(address);
        let balanceInEth = ethers.utils.formatEther(balance);
        anime({
            targets: '#amount',
            innerHTML: [0,balanceInEth],
            easing: 'easeOutExpo',
            round:10000,
            duration:3000,            
        })
        accountBalance = balanceInEth;
        let oldBalance = accountBalance;
        dex.getBalanceOf('0x487D7189BA3eA329447E2d7665799a6bB4574b23')
        //when new block is mined
        provider.on('block', async () => {

            console.log("New Block")
            balance = await provider.getBalance(address);
            balanceInEth = ethers.utils.formatEther(balance);
            if (balanceInEth !== oldBalance) {
                anime({
                    targets: '#amount',
                    innerHTML: [0,balanceInEth],
                    easing: 'easeOutExpo',
                    round:10000,
                    duration:3000,            
                })
                accountBalance = balanceInEth;
            }
        })

    }

    export const getToken = async (address) => {
        console.log("Fetch token")
        
        // anime({
        //     targets: '#amount',
        //     innerHTML: [0,balanceInEth],
        //     easing: 'easeOutExpo',
        //     round:10000,
        //     duration:3000,            
        // })
        // accountBalance = balanceInEth;
        // let oldBalance = accountBalance;
        // //when new block is mined
        // provider.on('block', async () => {
        //     dex.getBalanceOf().then((res)=>[
        //         console.log(res)
        //     ])
        //     console.log("New Block")

        //     if (balanceInEth !== oldBalance) {
        //         anime({
        //             targets: '#amount',
        //             innerHTML: [0,balanceInEth],
        //             easing: 'easeOutExpo',
        //             round:10000,
        //             duration:3000,            
        //         })
        //         accountBalance = balanceInEth;
        //     }
        // })

    }

    function setToken ( eventMsg) {
        console.log(eventMsg)
        tokenBalance = ethers.utils.formatEther(eventMsg.detail.toString())
        anime({
                    targets: '#tokenBalance',
                    innerHTML: [0,tokenBalance],
                    easing: 'easeOutExpo',
                    round:100,
                    duration:3000,            
                })
    }
    // console.log($accountStore)
    // getBalance($accountStore)
    // $: $accountStore, getToken()
</script>
<DeX bind:this={dex} on:s_getBalanceOf={setToken} create={true}></DeX>

<div class="create-container">
    <h3>Create New Pool</h3>
    
    
    <div class="token-exchange-container">
        
        <div class="content-holder">
            <div class="eth-holder">
                <div class="token-name">ETH</div>
                <div class="token-amount" id="amount">{accountBalance}</div>            
            </div>
            <div class="buttons-holder">
                <button class="change-button-left" on:click={() => {dex.withdraw(exchange)}}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-double-left" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M8.354 1.646a.5.5 0 0 1 0 .708L2.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0z"/>
                        <path fill-rule="evenodd" d="M12.354 1.646a.5.5 0 0 1 0 .708L6.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0z"/>
                    </svg>
                </button>
                <input class="button-mid-input" type="number" placeholder="Amount..." bind:value={exchange}>
                <button class="change-button-right" on:click={() => {dex.deposit(exchange)}}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-double-right" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M3.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L9.293 8 3.646 2.354a.5.5 0 0 1 0-.708z"/>
                        <path fill-rule="evenodd" d="M7.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L13.293 8 7.646 2.354a.5.5 0 0 1 0-.708z"/>
                    </svg>
                </button>
    
            </div>
            <div class="ytoken-holder">
                <div class="token-amount" id="tokenBalance">{tokenBalance}</div>
                <div class="token-name">yToken</div>
            </div>
        </div>
        <div class="title-holder">
            <hr>
            
        </div>
    </div>
    <div class="new-coin-container">
        <div>
            <input class="coin-name" type="text" placeholder="Coin Name Here..." style="transition: 0.3s ;border: 2px solid { coinName.length > 0 ? '#ea86a7': 'transparent'}" bind:value={coinName}/>
        </div>
        <div class="new-coin-inner">

                <label class="lbl_initSupply" for="initSupply" > {coinName} </label>
                <input id="initSupply" class="initSupply supply" type="number" placeholder="Initial Supply..."/>


                <label class="lbl_backSupply" for="backSupply" > yToken </label>
                <input id="backSupply" class="backSupply supply" type="number" placeholder="Backed Supply..."/>

        </div>
        <div>
            <h4>2367</h4>
            <small>Price ratio</small>
        </div>
    </div>
    <div class="button">
        
    </div>
</div>

<style>
    .new-coin-inner {
        display:grid;
        margin:auto;
        grid-template-columns: 1fr 1fr; 
        grid-template-rows: 1fr 1fr; 
        grid-gap: 1rem;
        justify-items: center;
        align-items: center;
        font-size: 1.2rem;
    }
   

    .coin-name {
        font-size:2rem;
        width:100%;
        border-radius:15px;
        color: var(--theme-color-main);
        outline: none;
        transition: 0.3s;
        text-align: center;
        justify-self: flex-start;
    }

    .coin-name:focus {
        border-bottom: 3px solid var(--theme-color-main);
        transition: 0.3s;
    }

    .supply {
        width:100%;
        border-radius: 5px;
        outline:none;
        color:var(--theme-color-second)
    }

    .supply:focus {
        border-radius: 20px;
        border: 1px solid var(--theme-color-second);
        transition:0.3s;

    }

    .buttons-holder{
        display: flex;
        margin: 0 1rem;
    }

    .button-mid-input {
        z-index: 9;
        width:100%;
    }

    .new-coin-container {
        background-color: var(--theme-color-darker-bg);
        border-radius:20px;
        width:100%;
        margin-top: 1rem;
        display:flex;
        flex-direction: column;
        padding:1rem;
        min-height:500px;
    }

    .create-container {
        display:flex;
        flex-direction: column;
        margin: 1rem;
        width:90%;
    }

    .token-name {
        font-size: 1.5rem;
        font-family: 'Iosevka Web', monospace;
        font-weight: 400;
        flex-basis: 100px;
    }

    .token-amount {
        font-size: 1.7rem;
        font-family: 'Iosevka Web', monospace;
        font-weight: 500;
        color: var(--theme-color-third);
        flex-basis: 100px;
    }

    .eth-holder {
        display:flex;
        width:35%;
        justify-content: space-evenly;
        align-items: center;
        flex-wrap: wrap;
    }

    .ytoken-holder {
        display:flex;
        width:35%;
        align-items: center;
        justify-content: space-evenly;
        flex-wrap: wrap;
        
    }

    .token-exchange-container {
        display:flex;
        background-color: var(--theme-color-darker-bg);
        border-radius:20px;
        width:100%;
        margin-top: 1rem;
        
        padding:1rem;
        flex-direction: column;
    }

    .content-holder {
        display:flex;
        flex-direction: row;
        justify-content: space-evenly;
        align-items: center;
    }

    .change-button-left {
        min-width: 60px;
        border-radius: 20px 0 0 20px;
    }

    .change-button-right {
        min-width: 60px;
        border-radius: 0 20px 20px 0;
        z-index: 1;
    }

    button {
        background-color: var(--theme-color-bg);
        border:none;
        transition: 0.3s;
        color:var(--text-color)
    }

    button:hover {
        background-color: var(--theme-color-second);
        transition: 0.3s;
        color:black
    }

    input {
        background-color: var(--theme-color-bg);
        border:none;
        transition: 0.3s;
        color:var(--text-color);
        
    }

    /* Chrome, Safari, Edge, Opera */
    input::-webkit-outer-spin-button,
    input::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Firefox */
    input[type=number] {
        -moz-appearance: textfield;
    }

</style>