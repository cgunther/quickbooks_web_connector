require 'spec_helper'
require 'rexml/document'

describe 'quickbooks_web_connector/qwc/qwc' do

  before { render }

  let(:root) { REXML::Document.new(rendered).root }

  it 'wraps everything in a QBWCXML element' do
    expect(root.name).to eq('QBWCXML')
  end

  it 'includes the app name' do
    expect(root.text('AppName')).to eq('My QBWC App')
  end

  it 'includes the app ID' do
    expect(root.text('AppID')).to be_nil
  end

  it 'includes the endpoint url' do
    expect(root.text('AppURL')).to eq('/path/to/endpoint')
  end

  it 'includes the description' do
    expect(root.text('AppDescription')).to eq('My QBWC App Description')
  end

  it 'includes the support url' do
    expect(root.text('AppSupport')).to eq('http://test.host/')
  end

  it 'includes the username' do
    expect(root.text('UserName')).to eq('foo')
  end

  it 'includes the owner id' do
    expect(root.text('OwnerID')).to eq('d69682e6-4436-44bc-bd19-d6bfbd11778d')
  end

  it 'includes the file id' do
    expect(root.text('FileID')).to eq('916222f3-c574-4c70-8c9d-e3cec2634e49')
  end

  it 'sets the type to QBFS' do
    expect(root.text('QBType')).to eq('QBFS')
  end

end
