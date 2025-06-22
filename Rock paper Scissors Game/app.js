let userscore = 0;
let compscore = 0;

const choices = document.querySelectorAll(".choice");
const msg=document.querySelector("#msg");
const userscorepara=document.querySelector("#user-score");
const compscorepara=document.querySelector("#comp-score");
 

const genCompChoice=() =>{
    const options=["rock","paper","scissors"];
    const randIdx= Math.floor(Math.random()*3);
    return options[randIdx];
 };
 const drawGame=() =>{
   msg.innerText=("Game was Draw ,Play Again!");  
     msg.style.backgroundColor = " #081b31";
 }
 
 const showWinner=(userwin ,userChoice,compChoice) =>{
    if(userwin){
        userscore++;
        userscorepara.innerText=userscore;
        msg.innerText=`You win! Your ${userChoice} beats ${compChoice}`;
     msg.style.backgroundColor = "green";

    }else{
        compscore++;
        compscorepara.innerText=compscore;
        
        msg.innerText=`You win! Your ${compChoice} beats  your ${userChoice}`;
         msg.style.backgroundColor = "red";
 }
 }
const playgame=(userChoice) =>{
    console.log("user choice=",userChoice);
   //Generate computer choice-> modular
  const compChoice=genCompChoice();
   console.log("comp choice=",compChoice);
   if(userChoice===compChoice){
    //Draw game
    drawGame();
   }else{
    let userwin=true;
    if(userChoice === "rock"){
        //scissors,paper
        userwin=compChoice ==="paper"? false :true;
        } else if(userChoice ==="paper"){
            //rock,scissors
            userwin=compChoice ==="scissors"? false :true;
        } else{
            //rock,paper
           userwin = compChoice === "rock" ? false : true;
        }
        showWinner(userwin,userChoice,compChoice);
   }
};

choices.forEach((choice) => {
    choice.addEventListener("click", () => {
        const userChoice=choice.getAttribute("id");
        console.log("choice was clicked",userChoice);
        playgame(userChoice);
    });
});
