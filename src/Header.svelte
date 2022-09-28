<script>
	import { Rainbow } from 'svelte-loading-spinners'
    import { fade } from 'svelte/transition';
    import { accountStore } from './stores/accountStore.js'
    import { ethers } from "ethers";
    import { notifications } from './stores/notifications.js'
    import jazzicon from "@metamask/jazzicon"
//     import { ethers } from "ethers";
// const provider = new ethers.providers.Web3Provider(window.ethereum)

// const ethbalance = await provider.getBalance(address)

    let src = '../logo.png'
	let userAddress = null;
    let accicon
	$: loading = false;
    $: accountBalance = 0;

	async function connectWallet() {
		loading = true;
		if (window.ethereum) {
			// ethereum is an object injected by the wallet. Let's check if is available
			const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' }).catch((e)=>{
                console.error(e)
                notifications.danger(e.message, 4000)
				loading = false;
			}); // use the request method to get the accounts, aka logging in to Metamask
			console.log(accounts)
            loading= false;
            if (accounts.length > 0) {
				// it returns an array of accounts, it should have at least 1 element
                    $accountStore = accounts[0]; // update the state
                    console.log($accountStore)
                    getBalance($accountStore);
                } else {
                    notifications.danger('No Ethereum Accounts Found', 4000)
                }
			
		}else {
			notifications.danger('No Ethereum Wallet Found', 4000)
		}			
	}

    export const getBalance = async (address) => {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const balance = await provider.getBalance(address);
        const balanceInEth = ethers.utils.formatEther(balance);
        accountBalance = balanceInEth;
    }

    const truncate = function (fullStr, strLen, separator) {
        if (fullStr.length <= strLen) return fullStr;

        separator = separator || '...';

        var sepLen = separator.length,
            charsToShow = strLen - sepLen,
            frontChars = Math.ceil(charsToShow/2),
            backChars = Math.floor(charsToShow/2);

        return fullStr.substr(0, frontChars) + 
            separator + 
            fullStr.substr(fullStr.length - backChars);
    };

    const genIcon = () => {
        
        const addr = $accountStore.slice(2, 10);
        const seed = parseInt(addr,16);
        const icon = jazzicon(30, seed);

        accicon.appendChild(icon) ;
    }
</script>


<nav class="navbar navbar-expand-lg bg-dark">
    <div class="container-fluid">
      <a class="navbar-brand" href="#">
        <img {src} style="width:25vh">
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"> 
            <svg xmlns="http://www.w3.org/2000/svg" width="30" height="30" fill="currentColor" class="bi bi-list" viewBox="0 0 16 16">
                <path fill-rule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z"/>
              </svg>
        </span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="#">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-grid-1x2-fill" viewBox="0 0 16 16">
                        <path d="M0 1a1 1 0 0 1 1-1h5a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H1a1 1 0 0 1-1-1V1zm9 0a1 1 0 0 1 1-1h5a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1h-5a1 1 0 0 1-1-1V1zm0 9a1 1 0 0 1 1-1h5a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1h-5a1 1 0 0 1-1-1v-5z"/>
                      </svg>
                    Dashboard
                </a>
              </li>
          <li class="nav-item">
            <a class="nav-link active" aria-current="page" href="#">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-shuffle" viewBox="0 0 16 16">
                    <path fill-rule="evenodd" d="M0 3.5A.5.5 0 0 1 .5 3H1c2.202 0 3.827 1.24 4.874 2.418.49.552.865 1.102 1.126 1.532.26-.43.636-.98 1.126-1.532C9.173 4.24 10.798 3 13 3v1c-1.798 0-3.173 1.01-4.126 2.082A9.624 9.624 0 0 0 7.556 8a9.624 9.624 0 0 0 1.317 1.918C9.828 10.99 11.204 12 13 12v1c-2.202 0-3.827-1.24-4.874-2.418A10.595 10.595 0 0 1 7 9.05c-.26.43-.636.98-1.126 1.532C4.827 11.76 3.202 13 1 13H.5a.5.5 0 0 1 0-1H1c1.798 0 3.173-1.01 4.126-2.082A9.624 9.624 0 0 0 6.444 8a9.624 9.624 0 0 0-1.317-1.918C4.172 5.01 2.796 4 1 4H.5a.5.5 0 0 1-.5-.5z"/>
                    <path d="M13 5.466V1.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384l-2.36 1.966a.25.25 0 0 1-.41-.192zm0 9v-3.932a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384l-2.36 1.966a.25.25 0 0 1-.41-.192z"/>
                  </svg>
                Swap
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-chevron-contract" viewBox="-2 0 16 16">
                    <path fill-rule="evenodd" d="M3.646 13.854a.5.5 0 0 0 .708 0L8 10.207l3.646 3.647a.5.5 0 0 0 .708-.708l-4-4a.5.5 0 0 0-.708 0l-4 4a.5.5 0 0 0 0 .708zm0-11.708a.5.5 0 0 1 .708 0L8 5.793l3.646-3.647a.5.5 0 0 1 .708.708l-4 4a.5.5 0 0 1-.708 0l-4-4a.5.5 0 0 1 0-.708z"/>
                  </svg>
                Create
            </a>
          </li>
          
        </ul>
        <div class="connect-holder">
            {#if $accountStore === null}
                {#if loading === false} 
                    <button class = 'connect'  on:click={connectWallet}>Connect Wallet </button>
                {:else}
                    <Rainbow color="#81d1e2"></Rainbow>
                {/if}
           
            {:else}
            <div class="amount-holder" transition:fade on:introend={() => {genIcon()}}>
                <div class="amount">{accountBalance} <strong>ETH</strong></div>
                <div class="addr">{truncate($accountStore,10)}</div>
                <div class="jazz" bind:this={accicon} transition:fade></div>
            </div>
            {/if}
            
            
          </div>
      </div>
      
    </div>
  </nav>

<!-- {#if userAddress}
	<p class = 'msg'>
		Successfullly connected with account: <strong>{userAddress}</strong>
	</p>
{:else}
	{#if loading === false}
        
	{:else}
			<div class = 'loading'>
				<Circle></Circle>
			</div>
	{/if}
{/if} -->

<style>
    .jazz {
        width:30px;
        height:30px;
    }

    .amount-holder {
        display:flex;
        align-items: center;
        padding: 0.4rem;
        margin: 0.3rem;
        border-radius: 15px;
        border: 2px solid var(--theme-color-second);
    }

    .amount {
        font-size: 1.2rem;
        font-family: 'Iosevka Web', monospace;
        margin-right: 0.7rem;
        padding-top:0.1rem;
        background-color: var(--theme-color-second);
        padding: 0.2rem;
        border-radius: 8px;
        color: var(--theme-color-darker-bg);
    }

    .addr {
        font-size: 1.2rem;
        font-family: 'Iosevka Web', monospace;
        margin-right: 0.7rem;
        padding-top:0.1rem;
    }

    .nav-link {
        display:flex;
        align-items: center;
        margin:0.5rem 1rem;
        width:100%;
        justify-content: center;
    }

    .nav-link svg {
        margin-right:0.2rem;
    }


    .nav-item a {
        color:var(--text-color);
        transition: 0.2s ease-in-out;
        text-decoration: none;
    }

    .nav-item a:hover {
        color:var(--theme-color-main);
        transition: 0.2s ease-in-out;
    }

    li {
        font-size: 1.25rem;
    }

    .navbar {
        border-radius: 20px;
    }


    .connect-holder {
        display:flex;
        width:100%;
        justify-content: flex-end;
    }

    .collapse {
    }

	.loading{
		position: absolute;
		margin-left: 47%;
		margin-top: 30vh;
	}

	.connect{
		font-size: 1.2rem;
		font-family: sans-serif;
		background-color:var(--theme-color-second);
		color: black;
		border-radius: 8px;
		transition-duration: 0.4s;
        padding: 0.5rem 1rem;
        min-width: 200px;
	}

	.connect:hover{
		background-color: var(--theme-color-main);
		color: white;
	}

    .navbar-toggler-icon {
        color: #ea86a7;
        background:none;
    }

	.msg{
		font-size: 16px;
		margin-top: 30vh;
	}

    @media (max-width: 992px) {
        .connect {
            
            flex-grow: 1;

            
        }

        .nav-link {

        }
    }
</style>