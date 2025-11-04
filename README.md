![SimulatorScreenRecording480](https://github.com/YangJe-Posh/CustomCollectionViewAnimationInSheetVC/blob/main/SimulatorScreenRecording480.gif)

# UICollectionView Animation Extension

An extension that makes it easy to apply custom animations to UICollectionView cells.

## Main Functions

### 1. `animate(cell:parameter:)`
Applies animation to a single cell.

```swift
collectionView.animate(
    cell: cell,
    parameter: animationParameter
)
```

### 2. `animateVisibleCells(parameter:)`
Applies animation to all visible cells simultaneously.

```swift
collectionView.animateVisibleCells(
    parameter: animationParameter
)
```

### 3. `animateVisibleCellsByRow(rowInterval:parameter:)`
Applies animation to visible cells sequentially by row.

```swift
collectionView.animateVisibleCellsByRow(
    rowInterval: 0.2,  // Delay between each row (seconds)
    parameter: animationParameter
)
```

## Usage Example

```swift
// Configure animation parameters
let animationTypes: Set<PoshmarkCollectionCellAnimationType> = [
    .opacity(animationOpacity: (starting: 0, finished: 1)),
    .slide(animationSliding: (isToIdentity: true, direction: .vertical, amount: 50))
]

let parameter = CollectionViewCellAnimationParameter(
    type: animationTypes,
    duration: 0.6,
    delay: 0,
    springWithDamping: 0.8,
    initialSpringVelocity: 0.3,
    options: .curveEaseOut
)

// Execute animation
collectionView.animateVisibleCellsByRow(
    rowInterval: 0.1,
    parameter: parameter
)
```

## Animation Types

### Opacity
```swift
.opacity(animationOpacity: (starting: 0, finished: 1))
```
- `starting`: Starting opacity (0.0 ~ 1.0)
- `finished`: Ending opacity (0.0 ~ 1.0)

### Slide
```swift
.slide(animationSliding: (isToIdentity: true, direction: .vertical, amount: 50))
```
- `isToIdentity`: If true, animates from offset position to identity; if false, vice versa
- `direction`: `.horizontal` or `.vertical`
- `amount`: Translation distance (points)

## Parameters

- `type`: Set of animation types (multiple types can be combined)
- `duration`: Animation duration (seconds)
- `delay`: Animation start delay (seconds)
- `springWithDamping`: Spring damping ratio (0.0 ~ 1.0)
- `initialSpringVelocity`: Initial spring velocity
- `options`: UIView animation options

