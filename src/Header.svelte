<script>
	import { Rainbow } from 'svelte-loading-spinners'
    import { accountStore } from './stores/accountStore.js'

//     import { ethers } from "ethers";
// const provider = new ethers.providers.Web3Provider(window.ethereum)

// const ethbalance = await provider.getBalance(address)

    let src = '../logo.png'
	let userAddress = null;
	$: loading = false;

	async function connectWallet() {
		loading = true;
		if (window.ethereum) {
			// ethereum is an object injected by the wallet. Let's check if is available
			const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' }).then(()=>{
                loading=false;
            }).catch((e)=>{
                console.error(e)
                alert(e.message)
				loading = false;
			}); // use the request method to get the accounts, aka logging in to Metamask
			
			if (accounts.length > 0) {
				// it returns an array of accounts, it should have at least 1 element
				$accountStore = accounts[0]; // update the state
			} else {
				alert('No ethereum accounts found');
			}
		}else {
			alert('No ethereum Wallet found');
		}
		
		
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
                <a class="nav-link" href="#">Dashboard</a>
              </li>
          <li class="nav-item">
            <a class="nav-link active" aria-current="page" href="#">Swap</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">Create</a>
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
            <div class="amount-holder">
                Money
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
    .nav-item a {
        color:var(--text-color);
        transition: 0.2s ease-in-out;
    }

    .nav-item a:hover {
        color:var(--theme-color-main);
        transition: 0.2s ease-in-out;
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
		font-size: 1rem;
		font-family: sans-serif;
		background-color:var(--theme-color-second);
		color: black;
		border-radius: 8px;
		transition-duration: 0.4s;
        padding: 0.5rem 1rem;
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
    }
</style>