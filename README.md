# Nila

Nila is a dialect of Coffeescript that leans towards a more Ruby oriented syntax. Nilac is the official compiler for the Nila language. Nila is still in its infancy and is not suitable for day to day usage.

## Requirements

You will definitely need

* Ruby (1.90>) and Rubygems
* Node.js with NPM 

## Installation

You can install Nila yourself through Rubygems. Just run:

    $ gem install nilac

## Usage

To compile your Nila file:

	$ nilac -c file.nila

To compile and run your Nila file (requires Node.js):

	$ nilac -r file.nila

A detailed documentation is available at https://github.com/adhithyan15/nila/wiki/Documentation

## Tests

We currently use a homemade micro-testing framework called **Shark** to test our code. You can run tests by calling

    $ Shark -t

Shark uses Cucumber like syntax and you can read all the tests we have written in the **Shark/features** directory and all the files used in the test are stored in the **Shark/test_files** directory. If you want to know more about Shark, please visit https://github.com/adhithyan15/shark  

## Issues and Bugs

We utilize Github's issues page to keep track of issues and bugs. You can also post feature requests there. We are trying to close as many issues as possible.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The project is licensed under MIT License. You can read the legalese below

Copyright (c) 2013 Adhithya Rajasekaran, Sri Madhavi Rajasekaran

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The project is licensed under MIT License. Please review license.md for more details. 
