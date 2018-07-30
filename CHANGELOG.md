### Unreleased

### 0.8.0 - 2018-07-29

* enhancements
  * Add `after_authenticate` config callback to run a custom block after the web connector authenticates

### 0.7.1 - 2018-03-01

* bug fix
  * Catch when QuickBooks calls ReceiveResponseXML with an error message and fail job rather than trying to perform handler
  * Replace non-ASCII characters in request XML data with decimal entities to fix QuickBooks being unable to parse such XML requests

### 0.7.0 - 2018-01-27

* enhancements
  * Add support for Rails 5.1
  * Add support for Ruby 2.5

* breaking change
  * Drop support for Rails 3.2, 4.0, 4.1, and 4.2
  * Drop support for Ruby 2.0 - 2.1

### 0.6.3 - 2018-01-20

* enhancements
  * Add support for Ruby 2.2 - 2.4 and Rails 4.2 and 5.0

### 0.6.2 - 2016-11-10

* bug fix
  * Remove jobs that fail to build their request XML from the queue, leaving them in the failure queue so processing can continue with the remaining jobs

### 0.6.1 - 2014-05-18

* bug fix
  * Improve session progress handling to properly account for jobs enqueued during the session and not stop prematurely once we reach the number of jobs that were queued when the session started

### 0.6.0 - 2014-11-14

* enhancements
  * Allow multiple users to sync with the same company file accessible at different paths for each user

### 0.5.0 - 2014-11-04

* enhancements
  * Return the actual progress percentage for the session in receiveResponseXML

### 0.4.0 - 2014-09-03

* enhancements
  * Allow dequeuing a job based on it's builder, handler, and arguments

### 0.3.0 - 2014-03-03

* enhancements
  * Allow the AppName and AppDescription used in the QWC file to be configurable

### 0.2.0 - 2014-01-31

* enhancements
  * Loosen rails dependency to work with rails 4

### 0.1.0 - 2013-11-21

* enhancements
  * Switch soap libraries to avoid iconv deprecation warning in Ruby 1.9
  * Ruby 1.9.3 or higher is required

### 0.0.6 - 2013-02-28

* bug fix
  * Return a successful response on GET requests to the endpoint to satisfy the certificate check request

### 0.0.5 - 2013-02-28

* bug fix
  * Respond to GET requests on the endpoint for certificate check request

### 0.0.4 - 2013-02-27

* enhancements
  * Store the builder, not XML in the queue to allow for retrying jobs that may generate new XML
  * Add QuickbooksWebConnector::Job.queued method for fetching a list of all queued jobs
  * Store failed jobs with their error and allow failed jobs to be requeued

### 0.0.3 - 2012-12-06

* enhancements
  * Remove all assets from engine, none are used

### 0.0.2 - 2012-12-06

* enhancements
  * Allow parent controller to be customizable

### 0.0.1 - 2012-12-06

Initial release
