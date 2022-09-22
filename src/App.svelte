<script>
    import Wallet from "./wallet.svelte";

</script>

<main>
	<Wallet></Wallet>
</main>

<style>
	:global(body){
		/* background-color:darkseagreen; */
		background: #282c34;
		min-height: 96vh;
	}
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	h1 {
		color: #ff3e00;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>