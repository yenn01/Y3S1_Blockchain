<script>
    import { accountStore } from '../stores/accountStore.js'
    import { notifications } from '../stores/notifications.js'
    import anime from 'animejs/lib/anime.es.js';
    import { ethers, utils } from "ethers";
    import DeX from './DeX.svelte';
    import { fly, fade } from 'svelte/transition';
    import { NavItem } from 'sveltestrap';
    import { empty } from 'svelte/internal';
    import { parseEther } from 'ethers/lib/utils.js';

    $: accountBalance = 0;
    $: tokenBalance = 0;
    let dex
    let coinName = ''
    let exchange
    let coins
    let coinAmt
    let tknAmount
    let exist = -1;
    $: gasFees=0;
    let initSupply;
    let kConstant =0;
    let backSupply;
    $: difference = 0;
    $: over = false;
    $: newPriceRatio = 0
    $:priceRatio = 0; 

    $: initSupply, calc()
    $: coinName, calc()
    $: backSupply, calc()
    $: $accountStore, getBalance($accountStore)

    function calc() {
        if(exist < 0) {
            priceRatio = (backSupply === undefined ? 0 : backSupply) / (initSupply === undefined ? 0 : initSupply)
            if(dex !== undefined) {
                dex.getAddPoolGas(coinName,initSupply,backSupply)
            }
        } else {
            priceRatio = tknAmount / coinAmt
            kConstant = priceRatio
            let newTkn = (backSupply === undefined ? 0 : backSupply) + tknAmount
            let newCoin = ((initSupply === undefined ? 0 : initSupply) + coinAmt)
            newPriceRatio =  newTkn / newCoin
            difference = (newPriceRatio - priceRatio) / priceRatio
            if ( Math.abs(difference) > 0.05) {
                console.log('over')
                over = true;
            } else {
                over = false;
            }
            if(dex !== undefined) {
                dex.getAddAmtGas(coinName,initSupply,backSupply)
            }
            
        }
        
    }

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
        dex.getBalanceOf(address)
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
            dex.getBalanceOf(address)
            dex.getAllActivePools()
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

    function saveCoins(eventMsg) {
        coins = eventMsg.detail
        console.log("coin")
        console.log(coins)
        checkExist()
    }

    function checkExist() {
        for(let i=0; i< coins.length;i++) {
            if(coinName === coins[i].name) {
                exist = i;
                break;
            } else {
                exist = -1;
            }
        }
        coinAmt = coins[exist].coinAmount.toNumber() / Math.pow(10,9)
        tknAmount = coins[exist].tokenAmount.toNumber()  / Math.pow(10,9)
        console.log(exist)
        calc()
    }
    // console.log($accountStore)
    // getBalance($accountStore)
    // $: $accountStore, getToken()
</script>
<DeX bind:this={dex} create={true} 
    on:s_getBalanceOf={setToken} 
    on:s_getAllActivePools={saveCoins} 
    on:s_withdraw={() => {notifications.success('Withdraw Successful',4000)}} 
    on:s_deposit={()=>{notifications.success('Deposit Successful',4000)}}
    on:s_getAddAmtGas={(eMsg) => { gasFees = ethers.utils.formatUnits(eMsg.detail.toString(),'ether')}}
></DeX>

<div class="create-container">
    <h3 in:fly={{y:20}}>{exist > -1? 'Add to Pool' : 'Create & Add to Pool'}</h3>
    
    
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
            <input class="coin-name" type="text" placeholder="Coin Name Here..." style="transition: 0.3s ;border: 2px solid { coinName.length > 0 ? '#ea86a7': 'transparent'}" bind:value={coinName} on:focusout={checkExist}/>
        </div>
        {#if exist > -1 }
        <div class="pool-amount-inner" transition:fade>

                <div>Current Coins</div>
                <div class="supply-amount">{coinAmt}</div>

                <div>Current yTokens</div>
                <div class="supply-amount">{tknAmount}</div>
        </div>
        <h3 class="add">Add?</h3>
        {/if}
        <div class="new-coin-inner">

                <label class="lbl_initSupply" for="initSupply" > {coinName} </label>
                <input id="initSupply" class="initSupply supply" type="number" placeholder="Initial Supply..." bind:value={initSupply}/>


                <label class="lbl_backSupply" for="backSupply" > yToken </label>
                <input id="backSupply" style="border:2px solid {backSupply > tokenBalance || backSupply === 0 || over == true ? "#E26D69" : 'transparent'}" class="backSupply supply" type="number" placeholder="Backed Supply..." bind:value={backSupply}/>
                {#if backSupply > tokenBalance || backSupply === 0 || over == true}
                <p class="warning-message" transition:fade>{backSupply > tokenBalance ? "Not enough yTokens." : backSupply === 0 ?'yTokens cannot be zero.' : over == true ? 'Ratio difference  >5%':''}</p>
                {/if}
        </div>
        <div class="coin-ratio-container">
            <div class="">
                {#if exist > -1}
                    <small transition:fade class="timelabel">OLD</small><br>
                {/if}
                    <small>1 {coinName} = </small>
                {#key priceRatio}
                    <h2 in:fly={{ y: -10 }}>{priceRatio.toFixed(5)}</h2>
                {/key}
                <small>yToken</small>
            </div>
            {#if exist > -1}
            <div class="difference" style="color: { difference * 100 > 0 ? '#81e292' : difference == 0 ? '#bfc2c7' : '#E26D69'}">{(difference*100).toFixed(2)}%</div>
            <div class="" transition:fade>
                <small class="timelabel">NEW</small><br>
                <small>1 {coinName} = </small>
                {#key newPriceRatio}
                    <h2 in:fly={{ y: -10 }} style="color: {over == true ? '#E26D69' : '#81e292'}">{newPriceRatio.toFixed(5)}</h2>
                {/key}
                <small>yToken</small>
            </div>
            {/if}
        </div>
        
      
        
      
    </div>
    {#if coinName.length > 0 && initSupply > 0 && backSupply > 0 && backSupply <= tokenBalance && exist === -1}
            <div class="button-container" in:fly={{y:20}} out:fly={{y:10}}>
                <button on:click={() => dex.addPool(coinName,initSupply,backSupply)}>Create Pool</button>
            </div>
            <div class='gas-fees'>
                <small class="inner-gas-fees">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-fuel-pump-fill" viewBox="0 0 16 16">
                        <path d="M1 2a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v8a2 2 0 0 1 2 2v.5a.5.5 0 0 0 1 0V8h-.5a.5.5 0 0 1-.5-.5V4.375a.5.5 0 0 1 .5-.5h1.495c-.011-.476-.053-.894-.201-1.222a.97.97 0 0 0-.394-.458c-.184-.11-.464-.195-.9-.195a.5.5 0 0 1 0-1c.564 0 1.034.11 1.412.336.383.228.634.551.794.907.295.655.294 1.465.294 2.081V7.5a.5.5 0 0 1-.5.5H15v4.5a1.5 1.5 0 0 1-3 0V12a1 1 0 0 0-1-1v4h.5a.5.5 0 0 1 0 1H.5a.5.5 0 0 1 0-1H1V2Zm2.5 0a.5.5 0 0 0-.5.5v5a.5.5 0 0 0 .5.5h5a.5.5 0 0 0 .5-.5v-5a.5.5 0 0 0-.5-.5h-5Z"/>
                      </svg>
                     {gasFees}
                    
                
                </small>
            </div>
    {:else if coinName.length > 0 && initSupply > 0 && backSupply > 0 && backSupply <= tokenBalance && exist > -1 && over == false}
        <div class="button-container" in:fly={{y:20}} out:fly={{y:10}}>
            <button on:click={() => dex.addAmt(coinName,initSupply,backSupply)}>Add to pool</button>
        </div>
        <div class='gas-fees'>
            <small class="inner-gas-fees">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-fuel-pump-fill" viewBox="0 0 16 16">
                    <path d="M1 2a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v8a2 2 0 0 1 2 2v.5a.5.5 0 0 0 1 0V8h-.5a.5.5 0 0 1-.5-.5V4.375a.5.5 0 0 1 .5-.5h1.495c-.011-.476-.053-.894-.201-1.222a.97.97 0 0 0-.394-.458c-.184-.11-.464-.195-.9-.195a.5.5 0 0 1 0-1c.564 0 1.034.11 1.412.336.383.228.634.551.794.907.295.655.294 1.465.294 2.081V7.5a.5.5 0 0 1-.5.5H15v4.5a1.5 1.5 0 0 1-3 0V12a1 1 0 0 0-1-1v4h.5a.5.5 0 0 1 0 1H.5a.5.5 0 0 1 0-1H1V2Zm2.5 0a.5.5 0 0 0-.5.5v5a.5.5 0 0 0 .5.5h5a.5.5 0 0 0 .5-.5v-5a.5.5 0 0 0-.5-.5h-5Z"/>
                  </svg>
                 {gasFees}
               
            
            </small>
        </div>
    
    {/if}
    
</div>

<style>
    .gas-fees {
        padding-top: 0.5rem;
    }

    .inner-gas-fees {
        display: flex;
        flex-direction: row;
        align-items: center;
    }

    .inner-gas-fees > svg {
        padding-right: 0.25rem;
    }

    .timelabel{
        color:var(--theme-color-second)
    }


    .supply-amount {
        color:var(--theme-color-second)
    }


    .pool-amount-inner {
        display:grid;
        grid-template-columns: 1fr 1fr; 
        grid-template-rows: 1fr 1fr ; 
        grid-gap: 1rem;
        margin: 1rem 0;
        justify-items: center;
        align-items: center;
        font-size: 1.2rem;
    }

    .pool-amount-inner > div {
        width:100%;
    }


    .button-container {

        min-width: 500px;
    }

    .button-container button {
        background-color: var(--theme-color-main);
        width:100%;
        color:black;
        border-radius: 10px;
    }

    .warning-message {
        grid-column: 1/3;
        color:#E26D69;
    }

    .coin-ratio-container {
        font-family: 'Iosevka Web', monospace;
        display:flex;
        justify-content: space-evenly;
        align-items: center;
    }


    .new-coin-inner {
        display:grid;
        margin:auto;
        grid-template-columns: 1fr 1fr; 
        grid-template-rows: 1fr 1fr 1fr; 
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
        max-width: 500px;
    }

    .coin-name:focus {
        border-bottom: 3px solid var(--theme-color-main) !important;
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
        border: 1px solid var(--theme-color-second) !important;
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
        max-width: 500px;
    }

    .create-container {
        display:flex;
        flex-direction: column;
        margin: 1rem;
        width:90%;
        align-items: center;
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

    h2 {
        color:var(--theme-color-third);
      
        margin:0;
    }
    
    small {
        font-weight: 600;
    }

</style>