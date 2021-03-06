require 'spec_helper'

describe 'dns::record' do

  let(:facts) do
    {
      :osfamily   => 'RedHat',
      :fqdn       => 'puppetmaster.example.com',
      :clientcert => 'puppetmaster.example.com',
      :ipaddress  => '192.168.1.1'
    }
  end

  let :pre_condition do
    'include dns'
  end

  context 'when creating CNAME record' do
    let(:title) { "foo.example.com" }
    let(:params) {{
      :target => "vm123.example.com.",
      :type   => "CNAME",
    }}

    it "should have valid record configuration" do
      verify_concat_fragment_exact_contents(subject, 'dns-static-example.com+02content-foo.example.com.dnsstatic', [
        'update add foo.example.com. CNAME vm123.example.com.',
      ])
    end
  end

  context 'when creating SRV record' do
    let(:title) { "www.example.com-http-backend1" }
    let(:params) {{
      :target => "vm123.example.com.",
      :label  => "_http._tcp.www",
      :zone   => "example.com",
      :priority => "10",
      :weight   => "60",
      :port     => "80",
      :type   => "SRV",
    }}

    it "should have valid record configuration" do
      verify_concat_fragment_exact_contents(subject, 'dns-static-example.com+02content-www.example.com-http-backend1.dnsstatic', [
        'update add _http._tcp.www.example.com. SRV 10 60 80 vm123.example.com.',
      ])
    end
  end

  context 'when creating CNAME with blank target' do
    let(:title) { "badcname.example.com" }
    let(:params) {{
      :type   => "CNAME",
    }}

    it { should_not compile }
  end

  context 'when creating SRV record with non-integer weight' do
    let(:title) { "badsrv.example.com" }
    let(:params) {{
      :label  => "_http._tcp.badsrv",
      :target => "vm123.example.com.",
      :zone   => "example.com",
      :priority => "10",
      :weight   => "badweight",
      :port     => "80",
      :type   => "SRV",
    }}

    it { should_not compile }
  end

end
