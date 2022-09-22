<script>
	import { Circle } from 'svelte-loading-spinners'

	let userAddress = null;
	let loading = false;

	async function connectWallet() {
		loading = true;
		if (window.ethereum) {
			// ethereum is an object injected by the wallet. Let's check if is available
			const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' }).catch((e)=>{
				loading = false;
			}); // use the request method to get the accounts, aka logging in to Metamask
			
			if (accounts.length > 0) {
				// it returns an array of accounts, it should have at least 1 element
				userAddress = accounts[0]; // update the state
			} else {
				alert('No ethereum accounts found');
			}
		}else {
			alert('No ethereum Wallet found');
		}
		
		
	}
</script>

{#if userAddress}
	<p class = 'msg'>
		Successfullly connected with account: <strong>{userAddress}</strong>
	</p>
{:else}
	{#if loading === false}
	<button
		class = 'connect'
		on:click={connectWallet} autofocus>Connect with Wallet</button>
	{:else}
			<div class = 'loading'>
				<Circle></Circle>
			</div>
	{/if}
{/if}

<style>
	.loading{
		position: absolute;
		margin-left: 47%;
		margin-top: 30vh;
	}

	.connect{
		font-size: 20px;
		font-family: sans-serif;
		background-color:#6E7480;
		color: black;
		border-radius: 8px;
		margin-top: 30vh;
		transition-duration: 0.4s;
	}

	.connect:hover{
		background-color: #343028;
		color: white;
	}

	.msg{
		font-size: 16px;
		margin-top: 30vh;
	}

</style>