<script>
    import { Button, Modal } from 'sveltestrap';
    import { accountStore } from '../stores/accountStore.js'
    import { notifications } from '../stores/notifications.js'

    let open = false;
    let size = "sm";
    let account = false;
    const toggle = () => { 
                size
                open = !open;
                };

    function swapToken(){
    if ($accountStore === null){
        account = false;
        notifications.danger("Wallet is not connected.",4000);
        } else{
            account = true;
        }
    }
</script>

<div class = 'swap_container'>
    <div class = 'swap_text'>Swap</div>
    <div class = 'second_container'>
        <div class = 'token_container'>
            <input class="token_input" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" type="text" placeholder="0" pattern="^[0-9]*[.,]?[0-9]*$" maxlength=50  inputmode="decimal">            
            <button type = "button" class="select_token" on:click={toggle}>Select Token</button> 
        </div>
           
    </div>
    <div class = 'pad'><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-down-up" viewBox="0 0 16 16">
        <path fill-rule="evenodd" d="M11.5 15a.5.5 0 0 0 .5-.5V2.707l3.146 3.147a.5.5 0 0 0 .708-.708l-4-4a.5.5 0 0 0-.708 0l-4 4a.5.5 0 1 0 .708.708L11 2.707V14.5a.5.5 0 0 0 .5.5zm-7-14a.5.5 0 0 1 .5.5v11.793l3.146-3.147a.5.5 0 0 1 .708.708l-4 4a.5.5 0 0 1-.708 0l-4-4a.5.5 0 0 1 .708-.708L4 13.293V1.5a.5.5 0 0 1 .5-.5z"/>
    </svg></div>
    <div class = 'second_container'>
        <div class = 'token_container'>
            <input class="token_input" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" type="text" placeholder="0" pattern="^[0-9]*[.,]?[0-9]*$" maxlength=50  inputmode="decimal">            
            <button type = "button" class="select_token" on:click={toggle}>Select Token</button> 
        </div>
    </div>
    <div class = 'swap'>
        <button type = 'button' class = 'swap_button' on:click={swapToken}>Swap</button>
    </div>
</div>

<Modal class = "first_modal" body header="Select a Token" isOpen = {open} {toggle} {size}>
    Hello
</Modal>

<style>

.swap_container{
    display: flex;
    flex-direction: column;
    border-radius: 15px;
    width: 35%;
    height: 50vh;
    background: var(--theme-color-darker-bg);
    text-align: left;
    margin-top: 2%;
    font-weight: 700;   
}

.swap_text{
    color:var(--text-color); 
    margin: 3%;
}

.token_container{
    margin-left: 3%;
    width: 65%;
    height: 14vh;
    border-radius: 10px;
    background: var(--theme-color-bg);
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    justify-content: space-around;
}

.second_container:hover{
    border: 2px solid var(--text-color);
}

.second_container{
    margin-left: 3%;
    background: var(--theme-color-bg);
    border-radius: 10px;
    width: 90%;
    border: 2px solid transparent;
}

.pad{
  align-self: center;
}

.select_token{
    width: 8vw;
    height: 5vh;
    color: var(--theme-color-darker-bg);
    background: var(--theme-color-second);
    border-radius: 10px;
}

.select_token:hover{
    background: var(--theme-color-main);
    color: white;
}

.token_input{
    border-radius: inherit;
    border: none !important;
    padding-top: 6vh;
    width: 100%;
    background: var(--theme-color-bg);
    border-color: var(--theme-color-bg);
    color: var(--text-color);
    font-size: 4vh;
    font-family: 'Iosevka Web', monospace;
}

.swap{
    display: flex;
    justify-content: center;
    padding-top: 3%;
}

.swap_button{
    border-radius: 10px;
    width: 5vw;
    height: 5vh;
    background: var(--text-color);
    color: var(--theme-color-bg);
}

textarea:focus, input:focus{
    outline: none;
}

</style>