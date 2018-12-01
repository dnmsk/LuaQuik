if getWorkingFolder then
  _app_path = getWorkingFolder()..'\\lua\\my\\'
  dofile(_app_path..'common\\index.lua')
else
  _app_path = ''
  dofile(_app_path..'common/index.lua')
end

Settings={}
Settings.period = 666
Settings.Name = "Volumes"

---------------------------------------------------------------------------------------
Indicator = Class:new({
  new = function(self, dsInfo)
    self.dsInfo = dsinfo
  end,
  Draw = function(self, index)

  end
})

function _Calculate()
  local CC={}
  local LL={}
  local VV={} 
  
  return function(ind,  _p,_N)

    local index = ind
    local MAX = 0
    local MAXV = 0
    local MIN = 0
    local RR = 0
    local jj = 0
    local kk = 0
        
    if index == 1 then
      VV={}
      CC={}
      LL={}
------------------
      VV[index]=V(index)
      CC[1]=0
      return nil
    end
------------------------------
      VV[index]=V(index)
    if index < (Size()-2) then return nil end
    
      MAX = H(index)
      MIN = L(index)
    for i = 0, _p-1 do
      MAX=math.max(MAX,H(index-i))
      MIN=math.min(MIN,L(index-i))
    end
    ----------------------------------------
    for i = 1, _N do CC[i]=0 end

    for i = 0, _p-1 do
     jj=math.floor( (H(index-i)-MIN)/(MAX-MIN)*(_N-1))+1
     kk=math.floor( (L(index-i)-MIN)/(MAX-MIN)*(_N-1))+1
      for k=1,(jj-kk) do
        CC[kk+k-1]=CC[kk+k-1]+V(index-i)/(jj-kk)
      end
    end
    --------------------
    MAXV = 0
    for i = 1, _N do MAXV=math.max(MAXV,CC[i])end

    for i = 1, _N do
      CC[i]=math.floor(CC[i]/MAXV*50)
    end
    ---------------------
    for i = 1, _N do
      LL[i]= i/_N*(MAX-MIN)+MIN
      if CC[i]==0 then LL[i]=nil end
    end
    
  for i = 1, 50+1 do
  for j = 1, _N do
    if CC[j]>i then
      SetValue(index-i, j, LL[j])
      else
      SetValue(index-i, j, nil)
      end
    end
    end   

      return unpack(LL)
  end
end
---------------------------------------------------------------------------------------

function Init()
  Indicator:new(getDataSourceInfo())
  Settings.line = {}
  for i = 1, 100 do
    Settings.line[i] = {}
    Settings.line[i] = {Color = RGB(128, 128, 128), Type = TYPE_LINE, Width = 0,1}
  end
  
  myFFF = FFF()
  return 100
end
function OnCalculate(index)
  return Indicator:Draw(index)
end