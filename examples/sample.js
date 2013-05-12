//Written in Nila and compiled into Javascript.Have fun!

//Visit http://adhithyan15.github.com/nila to know more!

(function() {
  
  var hello, msg, message, goal_reached, isprime, visitor_present, names;
  
  
  hello = "world";
  
  
  msg = "Nila";
  
  
  
  message = "Welcome to " + msg;
  
  
  goal_reached = 72;
  
  
  isprime = false;
  
  
  visitor_present = true;
  
  
  if (visitor_present) {
    
    console.log("Hello Visitor!");
    
  }
  
  names = ["adhi", "alex", "john", "bill", "kelly"];
  
  
  function printsquare(input_number) {
    //This is a very simple Nila function
    
    var add_number, isvalid;
    
    
    add_number = input_number + 10;
    
    
    isvalid = true;
    
    
    function square(number) {
      
      return number*number;
      
      
    }
    
    
    return console.log("Square of " + add_number + " is " + square(add_number));
    
    
  }
  
  
  console.log(printsquare(5));
  
  
  function welcome_message() {
    
    return console.log("Welcome to Nila!");
    
    
  }
  
  
  console.log(welcome_message());
  


}).call(this);
