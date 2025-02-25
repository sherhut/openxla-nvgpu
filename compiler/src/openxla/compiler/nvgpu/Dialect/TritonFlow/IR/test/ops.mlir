// RUN: iree-opt --iree-plugin=openxla-triton --split-input-file %s \
// RUN:   | iree-opt --iree-plugin=openxla-triton --split-input-file \
// RUN:   | FileCheck %s

triton.executable private @example {
  triton.executable.export @compute
  builtin.module {
    func.func @compute(%arg0: !tt.ptr<f32>) { return }
  }
}

// CHECK: triton.executable private @example {
// CHECK:   triton.executable.export public @compute
// CHECK:   builtin.module {
// CHECK:     func.func @compute(%[[ARG:.*]]: !tt.ptr<f32>)
// CHECK:   }
// CHECK: }

// -----

triton.executable private @example {
  triton.executable.export public @compute as("foo")
  builtin.module {
    func.func @compute(%arg0: !tt.ptr<f32>) { return }
  }
}

// CHECK: triton.executable.export public @compute as("foo")

// -----

triton.executable private @example {
  triton.executable.export @compute
  builtin.module {
    func.func @compute(%arg0: !tt.ptr<f32>) { return }
  }
}

func.func @main(%arg0: index, %arg1: tensor<4xf32>) {
  triton.dispatch @example::@compute[%arg0](%arg1) : (tensor<4xf32>) -> ()
  return
}

// CHECK: func @main(%[[ARG0:.*]]: index, %[[ARG1:.*]]: tensor<4xf32>)
// CHECK:   triton.dispatch @example::@compute[%arg0](%arg1)

// -----

triton.executable private @example {
  triton.executable.export @compute
  builtin.module {
    func.func @compute(%arg0: !tt.ptr<f32>) { return }
  }
}

func.func @main(%arg0: index, %arg1: tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %d0 = tensor.dim %arg1, %c0 : tensor<?xf32>
  triton.dispatch @example::@compute[%arg0](%arg1) : (tensor<?xf32>{%d0}) -> ()
  return
}

// CHECK: func @main(%[[ARG0:.*]]: index, %[[ARG1:.*]]: tensor<?xf32>)
// CHECK:   %[[C0:.*]] = arith.constant 0 : index
// CHECK:   %[[D0:.*]] = tensor.dim %[[ARG1]], %[[C0]] : tensor<?xf32>
// CHECK:   triton.dispatch @example::@compute[%arg0](%arg1)
// CHECK      : (tensor<?xf32>{%[[D0]]) -> ()

// -----

func.func private @triton(%arg0: !tt.ptr<f32>) {
  return
}

func.func @main(%arg0: tensor<4xf32>) {
  %c1 = arith.constant 1 : index
  triton.call @triton[%c1](%arg0) : (tensor<4xf32>) -> ()
  return
}

// CHECK: func @main(%[[ARG:.*]]: tensor<4xf32>)
// CHECK:   %[[C1:.*]] = arith.constant 1 : index
// CHECK:   triton.call @triton[%[[C1]]](%[[ARG]])

// -----

func.func private @triton(%arg0: !tt.ptr<f32>) {
  return
}

func.func @main(%arg0: tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %d0 = tensor.dim %arg0, %c0 : tensor<?xf32>
  triton.call @triton[%c1](%arg0) : (tensor<?xf32>{%d0}) -> ()
  return
}

// CHECK: func @main(%[[ARG:.*]]: tensor<?xf32>)
// CHECK:   %[[C0:.*]] = arith.constant 0 : index
// CHECK:   %[[C1:.*]] = arith.constant 1 : index
// CHECK:   %[[D0:.*]] = tensor.dim %[[ARG]], %[[C0]] : tensor<?xf32>
// CHECK:   triton.call @triton[%[[C1]]](%[[ARG]])
// CHECK:     : (tensor<?xf32>{%[[D0]]}) -> ()
