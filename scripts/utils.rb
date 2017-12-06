#!/usr/bin/env ruby

def dockers
  %w[ docker-deployment ]
end

def changes
  all = %x[git diff --name-only $TRAVIS_COMMIT_RANGE].split("\n")
  all
    .select { |path| !path.include? "README.md" }
    .select { |path| path[/[\w-]*\/.*/] }
end

def all_folders 
  changes.map { |f| f.gsub(/dockers\//, 'docker-')[/[\w-]*/] }.uniq
end

def dockers_to_build  
  all_folders & dockers
end

def print_env
  puts "TRAVIS_BRANCH: #{ENV['TRAVIS_BRANCH']}"
  puts "TRAVIS_TAG: #{ENV['TRAVIS_TAG']}"
  puts "TRAVIS_PULL_REQUEST: #{ENV['TRAVIS_PULL_REQUEST']}"
  puts "TRAVIS_COMMIT_RANGE #{ENV['TRAVIS_COMMIT_RANGE']}"
end
