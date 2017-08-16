# COOLTEST
---
A test framework focused on the output DTR (Detailed Test Result) generation. The main idea is that every test scenario that has to be tested, requires the DTR on the output. That DTR has a more or less standard template with sections. So, when you follow the Test Cases (TC) described in FAT/ATP, you are expecting to do some actions and have an output to assert on. COOLTEST will give you "tools" to prepare data, execute requests and extract data for each of the test steps from the TC. For assertions, it uses the RUBY built-in +test/unit+ gem. The target is to concentrate as less as possible on how to get the data, how to send the request, BUT more on creating various input data for simulating TCs, validate and capture the DTR.

You'll have methods to _extract/update/delete_ data from the DB, send SSH/HTTP requests, get the logs (application, requests/responses, etc.), validate the outcome and save all this into DTR. So, the final output/outcome of a TC run is the DTR.

== Installation
* Install Ruby 2.2 or higher (https://www.ruby-lang.org/en/downloads/)
* Install +bundler+ gem (http://bundler.io/)
* Run <tt>bundle install</tt> (this will install all the required gems)

== Usage
The tests are located in the +tests/+ folder.

To run a test:

<tt>
$ ruby tests/TC_file.rb --name TC<testcase_name>
</tt>

The DTRs will be saved in the +dtr/+ folder under the corresponding class name from the executed test file.

== Documentation
Currently the documentation is generated from the comments in the code, and can be found in the +docs/+ folder
