import { BooleanLike } from "common/react";

export interface GasInfoOverview {
  // Basic gas collection information
  total_pressure:number;
  total_moles:number;
  temperature:number;
  volume:number;
  // Specific gas information
  data_each_gas:Array<GasData>;
}

export interface DevBombSimData {
  // Specific gas information
  gas_data:GasInfoOverview;
  max_moles:number;
  // Consts/Config
  advanced_mode: boolean;
  use_temperature_unit: 'kelvin' | 'celsius' | 'farenheit';
  use_pressure_unit: 'pascals';
  use_matter_unit: 'moles';
  si_unit_used_contents: 'pressure' | 'matter';
  max_pressure: number;
  log_data:Array<FormattedLogs>
}

interface GasData {
  name:string;
  id:string;
  moles:number;
  pascals:number;
}

export interface UnitSelectionData {
  label:string;
  callback:() => void;
  enabled:boolean;
}

export interface GasOverviewProps {
  usedValue:number;
  maxValue:number;
  temperature:number;
  temperatureUnit:string;
  advancedMode:boolean;
  formatContents:(value:number) => string;
  formatTemperature:(value:number) => string;
  onChangeTemperature:(value:number) => void;
}

interface GasDataLogs {
  oxygen:number;
  nitrogen:number;
  carbon_dioxide:number;
  toxins:number;
  farts:number;
  radgas:number;
  nitrous_oxide:number;
  oxygen_agent_b:number;
  temperature:number;
  volume:number;
}

export interface FormattedLogs {
  pre:GasDataLogs;
  post:GasDataLogs;
  fire_mult:number;
  plasma_reaction:BooleanLike;
  temperature_scale:number;
  energy_released:number;
  fuel_burnt:number;
}


export interface SubmenuProps {
  act: (action:string, props?:Record<string, number|string|boolean>) => void;
  data:DevBombSimData;
}

export interface SwitchProps {
  enabled:boolean;
  callback: () => void;
  forceColor:string;
}

export interface PressureInfoProps {
  currentPressure:number;
  maxValue:number;
  formatContents: (value:number) => string;
  formatPressure: (value:number) => string;
  currentMoles:number;
  formatMatter: (value:number) => string;
  usePressure:boolean;
  advancedMode:boolean;
  width?:any;
  height?:any;
}

export interface GasSettingProps {
  id:string;
  name:string;
  usedValue:number;
  maxValue:number;
  currentPressure:number;
  currentMoles:number;
  onNewPressure:(gasID:string, unitContents:string, newValue:number) => void;
  formatContents:(value:number) => string;
  formatPressure:(value:number) => string;
  formatMatter:(value:number) => string;
  unitContents:string;
  siUnitContents:string;
  advancedMode:boolean;
}
