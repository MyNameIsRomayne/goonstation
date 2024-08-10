/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { UNIT_CELSIUS, UNIT_FARENHEIT, UNIT_KELVIN, UNIT_MOLES, UNIT_PASCALS } from './constants';
import { formatSiUnit } from '../../format';
import { toFixed } from 'common/math';

// Unit formatting (matter)

export const formatMoles = value => {
  return Number(value).toFixed(3) + ' moles';
};

// Unit pressure (pressure)

export const formatPascals = value => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

// Unit formatting (temperature)

export const formatKelvin = value => {
  return Number(value).toFixed(2) + '°K';
};

export const formatCelsius = value => {
  return Number(value).toFixed(2) + '°C';
};

export const formatFarenheit = value => {
  return Number(value).toFixed(2) + '°F';
};

// Unit conversion (temperature)

export const kelvinToCelcius = value => {
  return Number(value) - 273.15;
};

export const celsiusToFarenheit = value => {
  return (Number(value) * 1.8) + 32;
};

export const kelvinToFarenheit = value => {
  return celsiusToFarenheit(kelvinToCelcius(value));
};

// argh

let formatFunctionsMatter:Record<string, (n:number) => string> = {};
let formatFunctionsPressure:Record<string, (n:number) => string> = {};
let formatFunctionsTemperature:Record<string, (n:number) => string> = {};
// defines on separate lines because typscript is a fuck
formatFunctionsMatter[UNIT_MOLES] = formatMoles;
formatFunctionsPressure[UNIT_PASCALS] = formatPascals;
formatFunctionsTemperature[UNIT_CELSIUS] = formatCelsius;
formatFunctionsTemperature[UNIT_KELVIN] = formatKelvin;
formatFunctionsTemperature[UNIT_FARENHEIT] = formatFarenheit;

// *ahem* THESE FUNCTIONS TAKE IN MOLES/PASCALS/KELVIN RESPECTIVELY. thank you.
let conversionFunctionsMatter:Record<string, (n:number) => number> = {};
let conversionFunctionsPressure:Record<string, (n:number) => number> = {};
let conversionFunctionsTemperature:Record<string, (n:number) => number> = {};
// defines on separate lines. typescript is a fuck
conversionFunctionsMatter[UNIT_MOLES] = (moles:number) => { return moles; }; // lol
conversionFunctionsPressure[UNIT_PASCALS] = (pascals:number) => { return pascals; }; // lmao
conversionFunctionsTemperature[UNIT_KELVIN] = (kelvin:number) => { return kelvin; }; // rofl
conversionFunctionsTemperature[UNIT_CELSIUS] = (kelvin:number) => { return kelvinToCelcius(kelvin); };
conversionFunctionsTemperature[UNIT_FARENHEIT] = (kelvin:number) => { return kelvinToFarenheit(kelvin); };

export const formatKelvinAs = (unitOutAs:string, value:number) => {
  return formatFunctionsTemperature[unitOutAs](conversionFunctionsTemperature[unitOutAs](value));
};

export const formatMolesAs = (unitOutAs:string, value:number) => {
  return formatFunctionsMatter[unitOutAs](conversionFunctionsMatter[unitOutAs](value));
};

export const formatPascalsAs = (unitOutAs:string, value:number) => {
  return formatFunctionsPressure[unitOutAs](conversionFunctionsPressure[unitOutAs](value));
};
