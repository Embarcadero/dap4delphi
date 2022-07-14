unit BaseProtocol.Helpers;

interface

uses
  System.TypInfo;

type
  TGenericHelper = class
  public
    class procedure CreateFields(const AObject: TObject);
    class procedure FreeFields(const AObject: TObject);

    class procedure CreateIfClass(const ATypeInfo: PTypeInfo; var AValue);
    class function CreateGenericIfClass<T>(): T;
    class procedure FreeIfClass(const ATypeInfo: PTypeInfo; var AValue);
    class function FreeGenericIfInstance<T>(var AValue: T): boolean;
  end;

  PObject = ^TObject;

implementation

uses
  System.Rtti, BaseProtocol.Types;

{ TGenericHelper }

class procedure TGenericHelper.CreateFields(const AObject: TObject);
begin
  var LRttiCtx := TRttiContext.Create();
  try
    var LRttiType := LRttiCtx.GetType(AObject.ClassInfo);
    for var LRttiField in LRttiType.GetFields() do begin
      var LAttribute := LRttiField.GetAttribute<ManagedAttribute>();
      if Assigned(LAttribute) then begin
        var LValue: TValue;
        if (LRttiField.FieldType.TypeKind = tkClass) then begin
          var LObject: TObject := nil;
          CreateIfClass(LRttiField.FieldType.Handle, LObject);
          LValue := LObject;
        end else
          LValue := TValue.Empty;

        LRttiField.SetValue(AObject, LValue);
      end;
    end;
  finally
    LRttiCtx.Free();
  end;
end;

class procedure TGenericHelper.FreeFields(const AObject: TObject);
begin
  var LRttiCtx := TRttiContext.Create();
  try
    var LRttiType := LRttiCtx.GetType(AObject.ClassInfo);
    for var LRttiField in LRttiType.GetFields() do begin
      var LAttribute := LRttiField.GetAttribute<ManagedAttribute>();
      if Assigned(LAttribute) then begin
        if (LRttiField.FieldType.TypeKind = tkClass) then
          LRttiField.GetValue(AObject).AsObject().Free();
      end;
    end;
  finally
    LRttiCtx.Free();
  end;
end;

class procedure TGenericHelper.CreateIfClass(const ATypeInfo: PTypeInfo;
  var AValue);
begin
  if (ATypeInfo^.Kind = tkClass) then begin
    var LRttiCtx := TRttiContext.Create();
    try
      var LRttiType := LRttiCtx.GetType(ATypeInfo);
      for var LRttiMethod in LRttiType.GetMethods() do begin
        if LRttiMethod.IsConstructor and not LRttimethod.IsStatic then begin
          if Length(LRttimethod.GetParameters()) = 0 then begin
            TObject(AValue) := LRttimethod.Invoke(ATypeInfo^.TypeData^.ClassType, []).AsObject();
            Exit;
          end;
        end;
      end;
    finally
      LRttiCtx.Free();
    end;
  end
end;

class function TGenericHelper.CreateGenericIfClass<T>: T;
begin
  if (PTypeInfo(TypeInfo(T))^.Kind = tkClass) then begin
    CreateIfClass(TypeInfo(T), Result);
  end else
    Result := Default(T);
end;

class procedure TGenericHelper.FreeIfClass(const ATypeInfo: PTypeInfo;
  var AValue);
begin
  if (ATypeInfo^.Kind = tkClass) then begin
    TObject(AValue).Free();
  end;
end;

class function TGenericHelper.FreeGenericIfInstance<T>(var AValue: T): boolean;
begin
  if (PTypeInfo(TypeInfo(T))^.Kind = tkClass) then
    FreeIfClass(TypeInfo(T), AValue)
  else if (TypeInfo(T) = TypeInfo(TValue)) then begin
    var LValue := TValue.From<T>(AValue);
    if LValue.IsObject() then
      LValue.AsObject.Free();
  end;
end;

end.
