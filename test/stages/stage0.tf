terraform {
  required_providers {
    clis = {
      source  = "cloud-native-toolkit/clis"
    }
  }
}

provider "clis" {
  alias = "test"

  bin_dir = "${path.cwd}/test_bin_dir"
}

data clis_check clis_test {
  provider = clis.test

  clis = ["oc"]
}

resource local_file bin_dir {
  filename = "${path.cwd}/.bin_dir"

  content = data.clis_check.clis_test.bin_dir
}
