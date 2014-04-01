source 'https://api.berkshelf.com'

metadata

# Temporary, Berkshelf has issues downloading zookeeper cookbook
cookbook 'zookeeper', github: 'SimpleFinance/chef-zookeeper', tag: 'v1.6.1'

group :integration do
  cookbook 'zookeeper-apt',  path: 'test/cookbooks/zookeeper-apt'
end
