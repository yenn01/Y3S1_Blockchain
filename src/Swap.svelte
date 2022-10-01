<script>
    
</script>

<div class = 'swap_container'>
    <div class = 'swap_text'>Swap</div>
    <div class = 'second_container'>
        <div class = 'token_container'>
            <input class="token_input" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" type="text" placeholder="0" pattern="^[0-9]*[.,]?[0-9]*$" maxlength=50  inputmode="decimal"> 
        </div>
    </div>
    <div class = 'pad'><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-down-short" viewBox="0 0 16 16">
    <path fill-rule="evenodd" d="M8 4a.5.5 0 0 1 .5.5v5.793l2.146-2.147a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 1 1 .708-.708L7.5 10.293V4.5A.5.5 0 0 1 8 4z"/>
    </svg></div>
    <div class = 'second_container'>
        <div class = 'token_container'>

        </div>
    </div>
</div>

<style>

.swap_container{
    display: flex;
    flex-direction: column;
    border-radius: 15px;
    width: 25%;
    height: 35vh;
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
    width: 70%;
    height: 10vh;
    border-radius: 10px;
    background: var(--theme-color-bg);
}

.second_container:hover{
    border: 2px solid var(--theme-color-main);
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

.token_input{
    border-radius: inherit;
    border: none !important;
    padding-top: 6vh;
    width: 100%;
    height: 1vh;
    background: var(--theme-color-bg);
    border-color: var(--theme-color-bg);
    color: var(--text-color);
    font-size: 4vh;
}

textarea:focus, input:focus{
    outline: none;
}

</style>