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

The request builder is a Ruby class that responds to the `perform` method, which will receives any additional arguments you supply, and returns the XML to be send to QuickBooks. This example uses the [builder](https://github.com/jimweirich/builder) library to generate the XML.

```ruby
class AddCustomerBuilder

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

The response handler is a Ruby class that responds to the `perform` method, which will receive the response XML as a string and any additional arguments you specified when enqueueing the job. This example uses the REXML library to parse the XML response from QuickBooks.

```ruby
require 'rexml/document'

class AddCustomerHandler

  def self.perform(response_xml, customer_id)
    customer = Customer.find(customer_id)
    customer.quickbooks_list_id = REXML::Document.new(response_xml).root.text('QBXMLMsgsRs/CustomerAddRs/CustomerRet/ListID')
    customer.save!
  end

end
```

To enqueue a job, you might add this to your model as an `after_create` callback, or maybe your controller's create action:

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

First include it in your Gemfile:

```
$ cat Gemfile
...
gem 'quickbooks_web_connector'
...
```

Next install it with Bundler:

```
$ bundle install
```

Mount the engine in your routes.rb

```
mount QuickbooksWebConnector::Engine => "/quickbooks_web_connector"
```

TODO: Add note about config in initializer

Now start your application:

```
$ rails server
```

Contributing
============

Once you've made your great commits:

1. [Fork](https://help.github.com/forking/) QuickbooksWebConnector
2. Create a topic branch: `git checkout -b my_feature`
3. Push to your branch: `git push origin my_feature`
4. Create a [Pull Request](https://help.github.com/pull-requests/) from your branch
5. That's it!
