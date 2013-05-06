//Written in Nila and compiled into Javascript.Have fun!

//Visit http://adhithyan15.github.com/nila to know more!

(function() {
  
  var hello, msg, message, long_passage, goal_reached, isprime, names;
  
  
  hello = "world";
  
  
  msg = "Nila";
  
  
  message = "Welcome to " + msg;
  
  
  long_passage = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor \nincididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \nexercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute \nirure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla \npariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia\ndeserunt mollit anim id est laborum.";
  
  
  goal_reached = 72;
  
  
  isprime = false;
  
  
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
  
  
  printsquare(5);
  
  
  function welcome_message() {
    
    return console.log("Welcome to Nila!");
    
    
  }
  


}).call(this);
