<script>
    import Header from "./components/Header.svelte";
    import { Route, router } from 'tinro'; 
    import Toast from "./components/Toast.svelte";
	import Swap from "./components/Swap.svelte";
    import Dashboard from "./components/Dashboard.svelte";
    import About from "./components/About.svelte";
    import Create from "./components/Create.svelte";

    let header;
</script>

<svelte:head>
    <title>/swap</title>
    <link rel="icon" href="/favicon.ico" type="image/x-icon">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-u1OknCvxWvY5kfmNBILK2hRnQC3Pr17a+RTT6rIHI7NnikvbZlHgTPOOmMi466C8" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css">
 	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css">
    <link href="https://pvinis.github.io/iosevka-webfont/3.4.1/iosevka.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Silkscreen&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Titillium+Web:wght@700&display=swap" rel="stylesheet">
</svelte:head>

<main>
    <Toast></Toast>
    <Route path="/">  
        <About></About>
    </Route>
    <Route path="/app/*">
        <Header></Header>
        <div class="component-container">
            <Route path="/dashboard">
                <Dashboard></Dashboard>
            </Route>
            <Route path="/swap">
                <Swap></Swap>
            </Route>	
            	
            <Route path="/create">
                <Create></Create>
            </Route>
        </div>
    </Route>
</main>
<footer>
	<small>All Rights Reserved | &copy; 2022 y/swap</small>
</footer>

<style>
    
    :root {
        --text-color: #bfc2c7;
        --theme-color-main: #ea86a7;
        --theme-color-second : #81d1e2;
        --theme-color-third: #81e292;
        --theme-color-darker-bg: #212529;
		--theme-color-bg: #282c34;
    }

    .component-container {
        display:flex;
        flex-direction: column;
        align-items: center;
    }

	:global(body){
		/* background-color:darkseagreen; */
		background: #282c34 !important; 
		min-height: 96vh;
	}

    :global(select) {
        background-color: var(--theme-color-bg);
        color:var(--text-color)
    }
	main {
		text-align: center;
		padding: 1em;
		max-width: 992px;
		margin: 0 auto;
        color : var(--text-color);
        min-width:500px;
	}

	footer {
        color:var(--text-color);
        text-align: center;
    }


	@media (min-width: 500px) {
		main {
			max-width: none;
		}
	}
</style>