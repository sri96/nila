//Written in Nila and compiled into Javascript.Have fun!

//Nila is written and maintained by Adhithya Rajasekaran and Sri Madhavi Rajasekaran!

//Visit http://adhithyan15.github.com/nila to know more!

var hello, msg, message, goal_reached, isprime;


//This is a very basic Nila file. 

hello = "world";


msg = "Nila";


message = "Welcome to " + msg;


goal_reached = 72;


isprime = false;


function printsquare(input_number) {
  //This is a very simple Nila function
  
  var add_number, isvalid;
  
  
  add_number = input_number + 10;
  
  
  isvalid = true;
  
  
  function square(number) {
    
    return number*number;
    
    
  }
  
  
  console.log("Square of " + add_number + " is " + square(add_number));
  
  
}


printsquare(5);




