require 'spec_helper'

describe( 'stunnel::tun', :type => :define ) do
 context "with a basic tunnel" do
   let(:facts) {{ 'osfamily' => 'RedHat' }}
   let(:title) { 'my-tunnel' }
   let(:params) {{
     'accept' => '1234',
     'connect' => '2345',
   }}
   it do
     lines = [
       /accept=1234/,
       /connect=2345/,
       /pid\ =\ \/var\/run\/stunnel-my-tunnel.pid/,
       /output\ =\ \/var\/log\/stunnel\/my-tunnel\.log/,
       /debug\ =\ 5/,
       /TIMEOUTidle\ =\ 43200/,
     ]
     lines.each do |l|
       should contain_file('/etc/stunnel/conf.d/my-tunnel.conf').with_content(l)
     end
   end
 end 

 context "with non-defaults" do
   let(:facts) {{ 'osfamily' => 'RedHat' }}
   let(:title) { 'httpd' }
   let(:params) {{
     'accept' => '987',
     'connect' => 'localhost:789',
     'cert' => '/etc/pki/tls/cert/my-public.crt',
     'options' => 'NO_SSLv2',
     'install_service' => 'true',
     :output => '/var/log/stunnel/httpd-stunnel.log',
     :debug => '1',
     :service_opts => { 'TIMEOUTbusy' => '600' },
     :global_opts => { 'compression' => 'deflate' },
     :timeoutidle => '4000',
   }}
   it do
     should contain_service('stunnel-httpd').with({
       'enable' => true,
       'require' => 'File[/etc/init.d/stunnel-httpd]',
       'subscribe' => 'File[/etc/stunnel/conf.d/httpd.conf]',
     })

     lines = [
       /accept=987/,
       /connect=localhost:789/,
       /pid\ =\ \/var\/run\/stunnel-httpd.pid/,
       /cert\ =\ \/etc\/pki\/tls\/cert\/my-public.crt/,
       /options\ =\ NO_SSLv2/,
       /output\ =\ \/var\/log\/stunnel\/httpd-stunnel\.log/,
       /debug\ =\ 1/,
       /compression\ =\ deflate/,
       /TIMEOUTbusy\ =\ 600/,
       /TIMEOUTidle\ =\ 4000/,
     ]
     lines.each do |l|
       should contain_file('/etc/stunnel/conf.d/httpd.conf').with_content(l)
     end
   end
 end
end
