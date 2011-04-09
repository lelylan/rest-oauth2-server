# --------------
# Running Spec
# --------------

def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  run_spec_cmd(file)
end

def run_spec_cmd(cmd)
  puts "Running #{cmd}"
  system "bundle exec rspec #{cmd}"
end

# --------------
# Autodetection
# --------------

# Spec tests
watch("spec/.*/*_spec\.rb") do |match|
  run_spec match[0]
end

# Models tests
watch("app/models/(.*/.*)\.rb") do |match|
  run_spec %{spec/models/#{match[1]}_spec.rb}
end

# Acceptance tests for every controller (not the
# best solution, but it works pretty well)
watch("app/controllers/(.*/.*)\.rb") do |match|
  exclusions = ["controllers/application_controller"]
  unless exclusions.include? match[1]
    run_spec %{spec/acceptance/#{match[1]}_spec.rb}
  end
end

# ----------------
# Signal Handling
# ----------------

@second_int = false

# Run acceptance tests (Ctrl-\)
Signal.trap('QUIT') do
  run_spec "spec/acceptance/"
end

# Run all tests (Ctrl-c)
Signal.trap 'INT' do
  check_exit # exit  (double Ctrl-c)
  #@second_int = true
  run_spec "spec/"
end

def check_exit
  exit if @second_int
end
