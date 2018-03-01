# Unified Action Handling

This is a sample project which contains the unified action handling we use in XING's iOS app. We presented this on the CocoaHeads Hamburg meeting in January 2018.

The idea is to unify handling the tapping of cells, the tapping of buttons, and 3D touches. 

- Cells get a `selectionAction`, and a `previewAction`.
- Buttons can get a `action` (not shown in the sample yet).
- An action is of type `<NSDictionary<NSString *, id>` in Objective-C, and `Action` in Swift.
- An action can be dispatched via several dispatch methods.
- Action handlers (blocks/closures) can be registered up the responder chain.

We have seen less need for delegation with this approach, which shaves of a couple of lines of code. Also, we can work with composition instead of inheritance, as registering an action handler does not require yet another subclass.
