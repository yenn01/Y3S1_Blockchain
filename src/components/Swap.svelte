<script>
    import { Contract, ethers } from 'ethers';
    import { Button, Modal, ModalHeader, ModalBody} from 'sveltestrap';
    import { accountStore } from '../stores/accountStore.js'
    import { notifications } from '../stores/notifications.js'
    import DeX from './DeX.svelte';
    import { fade } from 'svelte/transition';

    let open = false;
    let open2 = false;
    let size = "sm";
    let res;
    $: inputAmountTok1 = 0;
    $: inputAmountTok2 = 0;
    let account = false;
    let dex;
    $: tokenName = '';
    $: tokenName2 = '';
    let temp;
    let temp2;
    let tokenSelected1 = false;
    let tokenSelected2 = false;
    $: token1Amount = 0;
    $: token2Amount = 0;
    const tokens = [];
    const tokenAmount = [];
    let gasPrice = 0;

    const toggle = () => { 
        size
        open = !open;
    };

    const toggle2 = () => { 
        size
        open2 = !open2;
    };

    function swapToken(){
        if ($accountStore === null){
            account = false;
            notifications.danger("Wallet is not connected.",4000);
        } else{
            account = true;
            if(tokenName != '' && tokenName2 != '' && inputAmountTok1 != 0 && inputAmountTok2 !=0){
                console.log(tokenName);
                console.log(tokenName2);
                console.log(inputAmountTok1);
                dex.exchangeBuy(tokenName,inputAmountTok1*Math.pow(10,9),tokenName2);
            }
        }
    }

    const loadActivePools = (eventMsg) => {
        console.log(eventMsg.detail)
        eventMsg.detail.forEach((element,index) => {
            tokens.push(element.name);
            tokenAmount.push(element.coinAmount);
        });
    }

    function onTokenClick(token){
        tokenSelected1 = true;
        tokenName = token;
        open = false;
        temp2 = tokens.indexOf(tokenName);
        token1Amount = tokenAmount[temp2];
        set_token2_amount();
        set_token1_amount();
    }

    function onTokenClick2(token){
        tokenSelected2 = true;
        tokenName2 = token;
        open2 = false;
        temp2 = tokens.indexOf(tokenName2);
        token2Amount = tokenAmount[temp2];
        set_token2_amount();
        set_token1_amount();
    }

    function switchToken(){
        if(tokenName != '' && tokenName2 != ''){
            temp = tokenName;
            tokenName = tokenName2;
            tokenName2 = temp;
            token2Amount = tokenAmount[tokens.indexOf(tokenName2)];
            token1Amount = tokenAmount[tokens.indexOf(tokenName)];
            set_token2_amount();
        }
    }

    function set_token2_amount(){
        if(tokenName != '' && tokenName2 != ''){
            if(tokenName2 != 'wBitcoin'){
                inputAmountTok2 = (inputAmountTok1 * (token2Amount/token1Amount)).toFixed(2);
            } else{
                inputAmountTok2 = (inputAmountTok1 * (token2Amount/token1Amount)).toFixed(4);
            }
        }
        if(inputAmountTok2 > tokenAmount[tokens.indexOf(tokenName2)]){
            notifications.danger("Amount of " + tokenName2 + " in the pool is not sufficient.",4000);
            inputAmountTok2 = 0;
            inputAmountTok1 = 0;
        }
        dex.getGasFee(tokenName,inputAmountTok1*Math.pow(10,9),tokenName2);       
    }

    function set_token1_amount(){
        if(tokenName != '' && tokenName2 != ''){
            inputAmountTok1 = (inputAmountTok2 * (token1Amount/token2Amount)).toFixed(2);
        }       
    }

    function token_clickable(token){
        if(token === tokenName || token === tokenName2){
            return false;
        }
    }

    function getGas(eventMsg){
        gasPrice = ethers.utils.formatUnits(eventMsg.detail.toString(), "ether");
    }
</script>

<DeX bind:this={dex} swap={true} on:s_getAllActivePools={loadActivePools} on:s_getGasFee={getGas} on:s_exchangeBuy={()=>{notifications.success("Transaction Completed!",4000);}}></DeX>

    <div class = 'swap_container'>
        <div class = 'swap_text'>Swap</div>
        <div class = 'second_container'>

            <!-- <div class = 'token_container'> -->
                <input id = 'token1' class="token_input" bind:value={inputAmountTok1} on:change={set_token2_amount} oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" type="text" placeholder="0" pattern="^[0-9]*[.,]?[0-9]*$" maxlength=50  inputmode="decimal">      
                {#if tokenSelected1 === false}      
                    <button type = "button" class="select_token" on:click={toggle}><div class='tok-button-container'>Select Token<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-caret-down-fill" viewBox="0 0 16 16">
                    <path d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"/>
                    </svg></div></button> 
                {:else if tokenSelected1 === true || tokenName != ''}
                    <button type = "button" class="select_token" on:click={toggle}>
                        <div class='tok-button-container'>
                            <div>{tokenName}</div>
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-caret-down-fill" viewBox="0 0 16 16">
                                <path d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"/>
                            </svg>
                        </div>
                    </button> 
                {/if}
            <!-- </div> -->
            
        </div>
        <div class = 'pad' on:click={switchToken}><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-down-up" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M11.5 15a.5.5 0 0 0 .5-.5V2.707l3.146 3.147a.5.5 0 0 0 .708-.708l-4-4a.5.5 0 0 0-.708 0l-4 4a.5.5 0 1 0 .708.708L11 2.707V14.5a.5.5 0 0 0 .5.5zm-7-14a.5.5 0 0 1 .5.5v11.793l3.146-3.147a.5.5 0 0 1 .708.708l-4 4a.5.5 0 0 1-.708 0l-4-4a.5.5 0 0 1 .708-.708L4 13.293V1.5a.5.5 0 0 1 .5-.5z"/>
        </svg></div>
        <div class = 'second_container'>
            <!-- <div class = 'token_container'> -->
                <input id = 'token2' class="token_input" bind:value={inputAmountTok2} on:change={set_token1_amount} oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" type="text" placeholder="0" pattern="^[0-9]*[.,]?[0-9]*$" maxlength=50  inputmode="decimal">            
                {#if tokenSelected2 === false}      
                    <button type = "button" class="select_token" on:click={toggle2}><div class='tok-button-container'>Select Token<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-caret-down-fill" viewBox="0 0 16 16">
                    <path d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"/>
                    </svg></div></button> 
                    {:else if tokenSelected2 === true || tokenName2 != ''}
                    <button type = "button" class="select_token" on:click={toggle2}>
                        <div class='tok-button-container'>
                            <div>{tokenName2}</div>
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-caret-down-fill" viewBox="0 0 16 16">
                                <path d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"/>
                            </svg>
                        </div>
                </button> 
                {/if}
            <!-- </div> -->
        </div>
        <div class = 'bottom_container'>
            <div class='equivalent_price_container'>
                {#if tokenName != '' && tokenName2 != ''}
                    1 {tokenName2} = {(token1Amount/token2Amount).toFixed(4)} {tokenName}
                    <!-- {#if document.} -->
                {/if}
            </div>
        </div>
        {#if tokenName != '' && tokenName2 != '' && inputAmountTok1 != 0 && inputAmountTok2 != 0}
            <div class = 'gas_fee_container' transition:fade>
                <div class = 'gas_text'><span class = 'tooltiptext' transition:fade>Estimated Gas Fee </span><div class = 'gas'><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-fuel-pump" viewBox="0 0 16 16">
                    <path d="M3 2.5a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 .5.5v5a.5.5 0 0 1-.5.5h-5a.5.5 0 0 1-.5-.5v-5Z"/>
                    <path d="M1 2a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v8a2 2 0 0 1 2 2v.5a.5.5 0 0 0 1 0V8h-.5a.5.5 0 0 1-.5-.5V4.375a.5.5 0 0 1 .5-.5h1.495c-.011-.476-.053-.894-.201-1.222a.97.97 0 0 0-.394-.458c-.184-.11-.464-.195-.9-.195a.5.5 0 0 1 0-1c.564 0 1.034.11 1.412.336.383.228.634.551.794.907.295.655.294 1.465.294 2.081v3.175a.5.5 0 0 1-.5.501H15v4.5a1.5 1.5 0 0 1-3 0V12a1 1 0 0 0-1-1v4h.5a.5.5 0 0 1 0 1H.5a.5.5 0 0 1 0-1H1V2Zm9 0a1 1 0 0 0-1-1H3a1 1 0 0 0-1 1v13h8V2Z"/>
                </svg> : {gasPrice} ETH </div></div>
            </div>
        {/if}
        <div class = 'swap'>
            <button type = 'button' class = 'swap_button' on:click={swapToken}>Swap</button>
        </div>
    </div>


<Modal modalClassName= 'first_modal' isOpen = {open} {toggle} {size}>
    <ModalHeader {toggle}>Select a token</ModalHeader>
    <ModalBody>
        {#each tokens as token}
            {#if token_clickable(token) === false}
                <div class = 'selected-token-container'>{token}</div>
                {:else}
                    <div class = 'token-name-container' on:click={() => onTokenClick(token)}>{token}</div>
            {/if}
        {/each}
    </ModalBody>
</Modal>

<Modal modalClassName = 'second_modal' isOpen = {open2} toggle={toggle2} {size}>
    <ModalHeader toggle={toggle2}>Select a token</ModalHeader>
    <ModalBody>
        {#each tokens as token}
            {#if token_clickable(token) === false}
                <div class = 'selected-token-container'>{token}</div>
                {:else}
                    <div class = 'token-name-container' on:click={() => onTokenClick2(token)}>{token}</div>
            {/if}
        {/each}
    </ModalBody>
</Modal>

<style>

:global(.modal-content){
    color: var(--text-color) !important;
    background-color: var(--theme-color-bg) !important;
}

.outmost_container{
    display: flex;
    justify-content: center;
}

.selected-token-container{
    margin-bottom: 3vh;
    pointer-events: none;
    opacity: 50%;
}

.equivalent_price_container{
    display: flex;
    text-align: center;
}

.gas_text{
    display: flex;
}

.gas{
    background-color: var(--theme-color-bg);
    border-radius: 10px;
    padding: 0.5rem 1rem;
}

.bottom_container{
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-top: 0.7rem;
}

.gas_text .tooltiptext{
    padding-right: 0.2rem;
    display: flex;
    flex-direction: column;
    justify-content: center;
    visibility: hidden;
}

.gas_text:hover .tooltiptext {
  visibility: visible;
}

.gas_fee_container{
    display: flex;
    justify-content: flex-end;
    
    margin-right:5%;
    align-self: flex-end;
}

.tok-button-container{
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 1.3rem;
}

.token-name-container{
    margin-bottom: 3vh;
    cursor: pointer;
}

.swap_container{
    display: flex;
    flex-direction: column;
    border-radius: 15px;
    min-width: 500px;
    min-height:600px;
    background: var(--theme-color-darker-bg);
    text-align: left;
    margin-top: 2%;
    font-weight: 700;   
    align-items: center;
}

.swap_text{
    color:var(--theme-color-third); 
    margin: 5%;
    align-self: flex-start;
    font-size: 1.4rem;
}

/* .token_container{
    margin-left: 3%;
    width: 65%;
    height: 14vh;
    border-radius: 10px;
    background: var(--theme-color-bg);
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    justify-content: space-around;
} */

.second_container:hover{
    border: 2px solid var(--text-color);
}

.second_container{
    background: var(--theme-color-bg);
    border-radius: 10px;
    width: 90%;
    border: 2px solid transparent;
    display:flex;
    flex-direction:row;
    align-items:center;
    padding: 0.2rem 1.5rem;
}

.pad{
  align-self: center;
  cursor: pointer;
}

.select_token{
    width: 45%;
    height: 80%;
    color: var(--theme-color-darker-bg);
    background: var(--theme-color-second);
    border-radius: 10px;
    font-family: 'Titillium Web', sans-serif;
    transition-duration: 0.4s;
}

.select_token:hover{
    background: var(--theme-color-main);
    color: white;
}

.token_input{
    border-radius: inherit;
    border: none !important;

    width: 100%;
    background: var(--theme-color-bg);
    border-color: var(--theme-color-bg);
    color: var(--text-color);
    font-size: 3rem;
    font-family: 'Iosevka Web', monospace;
}

.swap{
    display: flex;
    justify-content: center;
    padding-top: 0.8rem;
}

.swap_button{
    border-radius: 10px;
    min-width: 100px;
    padding: 0.5rem 1rem;
    font-size: 1.2rem;
    background: var(--text-color);
    color: var(--theme-color-bg);
}

.swap_button:hover{
    background: var(--theme-color-bg);
    color: var(--text-color);
}

textarea:focus, input:focus{
    outline: none;
}

@media (max-width: 600px) {
        .swap_container { 
            width: 100%;
        }
    }

</style>