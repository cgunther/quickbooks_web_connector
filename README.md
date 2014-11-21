QuickbooksWebConnector
======================

QuickbooksWebConnector is a Redis-backed library for queueing up requests for the Quickbooks Web Connector software to fetch and perform. Responses from the Quickbooks Web Connector can also be handled if you need to take some action with the result.

QuickbooksWebConnector is heavily inspired by [QBWC](https://github.com/skryl/qbwc) and [Resque](https://github.com/defunkt/resque), so many thanks to the great people behind those gems.

Requirements
------------

QuickbooksWebConnector is tested on Rails 3.2, 4.0, and 4.1 as well as Ruby 1.9, 2.0, and 2.1.

Usage
--------

QuickbooksWebConnector requires you to specify both a request builder and a request handler for generating and processing your job, respectively.

The request builder should be a Ruby class that responds to the `perform` method, which will receive any additional arguments you supply when enqueueing the job, and returns the XML to be sent to QuickBooks. This example uses the [builder](https://github.com/jimweirich/builder) library to generate the XML.

```ruby
class AddCustomerBuilder

  # customer_id would be passed as the 3rd argument to QuickbooksWebConnector.enqueue
  def self.perform(customer_id)
    customer = Customer.find(customer_id)

    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.instruct! :qbxml, version: '6.0'
    xml.QBXML do
      xml.QBXMLMsgsRq onError: 'stopOnError' do
        xml.CustomerAddRq do
          xml.CustomerAdd do
            xml.Name customer.name
          end
        end
      end
    end
  end

end
```

The response handler should be a Ruby class that responds to the `perform` method, which will receive the response XML as a string and any additional arguments you specified when enqueueing the job. This example uses the REXML library to parse the XML response from QuickBooks.

```ruby
require 'rexml/document'

class AddCustomerHandler

  # customer_id would be passed as the 3rd argument to QuickbooksWebConnector.enqueue
  def self.perform(response_xml, customer_id)
    customer = Customer.find(customer_id)
    customer.quickbooks_list_id = REXML::Document.new(response_xml).root.text('QBXMLMsgsRs/CustomerAddRs/CustomerRet/ListID')
    customer.save!
  end

end
```

To enqueue a job, you might add a line like this to your model as an `after_create` callback, or maybe your controller's create action:

```ruby
class Customer

  after_create :add_to_quickbooks

  def add_to_quickbooks
    QuickbooksWebConnector.enqueue AddCustomerBuilder, AddCustomerHandler, id
  end

end
```

Installing QuickbooksWebConnector
=================================

First, include it in your Gemfile:

```ruby
gem 'quickbooks_web_connector'
```

Next, install it with Bundler:

```
$ bundle install
```

Mount the engine in your routes.rb:

```ruby
mount QuickbooksWebConnector::Engine => "/quickbooks_web_connector"
```

Configure it by creating a file in `config/initializers` named `quickbooks_web_connector.rb`

```ruby
QuickbooksWebConnector.configure do |c|
  # Username, password, path to QBW file
  c.user 'web_connector', 'top-secret-password', 'C:\path\to\company\file.QBW'
end
```

Now start your application:

```
$ rails server
```

Now perform some actions in you application that will queue up some jobs, then run the Web Connector application to have QuickBooks process those jobs.

Contributing
============

Once you've made your great commits:

1. [Fork](https://help.github.com/forking/) QuickbooksWebConnector
2. Create a topic branch: `git checkout -b my_feature`
3. Push to your branch: `git push origin my_feature`
4. Create a [Pull Request](https://help.github.com/pull-requests/) from your branch
5. That's it!
