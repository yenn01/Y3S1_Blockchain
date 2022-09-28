<script>
    import Header from "./components/Header.svelteader.svelte";
    import { Route, router } from 'tinro'; 
    import Toast from "./components/Toast.svelte";


    let header;
</script>

<svelte:head>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-u1OknCvxWvY5kfmNBILK2hRnQC3Pr17a+RTT6rIHI7NnikvbZlHgTPOOmMi466C8" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css">
 	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css">
    <link href="https://pvinis.github.io/iosevka-webfont/3.4.1/iosevka.css" rel="stylesheet" />
</svelte:head>

<main>
    <Toast></Toast>
    <Route path="/">  </Route>
    <Header></Header>
    <div class="component-container">
        <Route path="/swap">
           
             Swap Here :D 
             
            
        </Route>
    </div>
</main>

<style>
    :root {
        --text-color: #bfc2c7;
        --theme-color-main: #ea86a7;
        --theme-color-second : #81d1e2;
        --theme-color-third: #81e292;
        --theme-color-darker-bg: #212529;
    }


	:global(body){
		/* background-color:darkseagreen; */
		background: #282c34 !important;
		min-height: 96vh;
        
	}
	main {
		text-align: center;
		padding: 1em;
		max-width: 992px;
		margin: 0 auto;
        color : var(--text-color);
        min-width:500px;
	}

	h1 {
		color: #ff3e00;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
	}

	@media (min-width: 500px) {
		main {
			max-width: none;
		}
	}
</style>