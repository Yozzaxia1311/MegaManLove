
local ffi = require "ffi"

ffi.cdef[[
typedef const char* gme_err_t;
typedef struct Music_Emu Music_Emu;
gme_err_t gme_open_file( const char path [], Music_Emu** out, int sample_rate );
gme_err_t gme_open_data( void const* data, long size, Music_Emu** out, int sample_rate );
int gme_track_count( Music_Emu const* );

gme_err_t gme_start_track( Music_Emu*, int index );
gme_err_t gme_play( Music_Emu*, int count, short out [] );

void gme_set_tempo( Music_Emu*, double tempo);
void gme_enable_accuracy( Music_Emu*, int enabled);

typedef struct gme_info_t
{
	/* times in milliseconds; -1 if unknown */
	int length;			/* total length, if file specifies it */
	int intro_length;	/* length of song up to looping section */
	int loop_length;	/* length of looping section */

	/* Length if available, otherwise intro_length+loop_length*2 if available,
	otherwise a default of 150000 (2.5 minutes). */
	int play_length;

	int i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15; /* reserved */

	/* empty string ("") if not available */
	const char* system;
	const char* game;
	const char* song;
	const char* author;
	const char* copyright;
	const char* comment;
	const char* dumper;

	const char *s7,*s8,*s9,*s10,*s11,*s12,*s13,*s14,*s15; /* reserved */
} gme_info_t;
gme_err_t gme_track_info( Music_Emu const*, gme_info_t** out, int track );
void gme_free_info( gme_info_t* );

int gme_voice_count( Music_Emu const* );
const char* gme_voice_name( Music_Emu const*, int i );
void gme_mute_voice( Music_Emu*, int index, int mute );
void gme_mute_voices( Music_Emu*, int muting_mask );

void gme_delete( Music_Emu* );
]]

local gme = ffi.load("libgme")

ffi.metatype("Music_Emu", {
    __gc = function (emu)
      gme.gme_delete(emu)
    end
  })

ffi.metatype("gme_info_t", {
    __gc = function (info)
      gme.gme_free_info(info)
    end
  })

local INFO_STR = { "system", "game", "song", "author", "copyright", "comment", "dumper" }
local INFO_INT = { "length", "intro_length", "loop_length", "play_length" }

local LoveGme = {}
LoveGme.__index = LoveGme

local function err_hand(result)
  local err = ffi.new("gme_err_t", result)
  if err ~= nil then -- not null pointer
    error(ffi.string(err))
  end 
end 

local function new(rate, buf, arg_count_buf)
  local new = setmetatable({}, LoveGme)
  new.sample_rate = rate or 44100
  new.buf_size = buf or 1024

  new.voice_count = 0
  new.track_count = 0
  new.current_track = 0

  new.playing = false
  new.hasTrack =  false

  new.source_params = {new.sample_rate, 16, 2, arg_count_buf}
  new.source = love.audio.newQueueableSource(unpack(new.source_params))
  new.emu = ffi.new("Music_Emu*[1]")
  new.ptr_info = ffi.new("gme_info_t*[1]")
  new.info = {}

  return new
end

function LoveGme:loadFile(fileName)
  self.source = love.audio.newQueueableSource(unpack(self.source_params))
  local fileData = love.filesystem.newFileData(fileName)
  err_hand(gme.gme_open_data(
      fileData:getFFIPointer(), 
      fileData:getSize(), 
      self.emu, 
      self.sample_rate
    ))
  fileData:release()
  self.track_count = gme.gme_track_count( self.emu[0] )
  self.voice_count = gme.gme_voice_count( self.emu[0] )
  self:setTrack(0)
end

function LoveGme:setTrack(track)
  self.source:stop()
  if self.track_count==0 or track >= self.track_count then
    error("no track "..track)
  end
  self.current_track = track
  err_hand( gme.gme_track_info( self.emu[0], self.ptr_info, track) )
  local c_info = self.ptr_info[0]
  for _,name in ipairs(INFO_STR) do
    self.info[name] = ffi.string(c_info[name])
  end
  for _,name in ipairs(INFO_INT) do
    self.info[name] = tonumber(c_info[name])
  end
  err_hand( gme.gme_start_track( self.emu[0], self.current_track ) )
  self.hasTrack = true
end

function LoveGme:renderTrackData(track, length)
  self:setTrack(track)
  local samples = math.floor((length)*self.sample_rate/2)*2
  local sd = love.sound.newSoundData(samples/2, self.sample_rate, 16, 2)
  err_hand( gme.gme_play( self.emu[0], samples, sd:getPointer()) )
  return sd
end

function LoveGme:update()
  if not self.hasTrack then return end
  while self.source:getFreeBufferCount() > 0 do
    local sd = love.sound.newSoundData(self.buf_size/2, self.sample_rate, 16, 2)
    err_hand( gme.gme_play( self.emu[0], self.buf_size, sd:getPointer()) )
    self.source:queue(sd)
    sd:release()
    if self.playing then self.source:play() end
  end
end

function LoveGme:setTempo(tempo)
  gme.gme_set_tempo(self.emu[0], tempo)
end

function LoveGme:enableAccuracy(bool)
  gme.gme_enable_accuracy( self.emu[0], bool )
end

function LoveGme:getVoiceName(voice)
  self:voice_error_check(voice)
  return ffi.string( gme.gme_voice_name( self.emu[0], voice ) )
end

function LoveGme:muteVoice(voice, bool)
  self:voice_error_check(voice)
  gme.gme_mute_voice( self.emu[0], voice, bool)
end

function LoveGme:muteVoices(mask)
  gme.gme_mute_voices( self.emu[0], mask )
end

function LoveGme:play()
  self.source:play()
  self.playing = true
end

function LoveGme:pause()
  self.source:pause()
  self.playing = false
end

function LoveGme:stop()
  self.source:stop()
  self.playing = false
end

function LoveGme:setVolume(v)
  self.source:setVolume(v or self.source:getVolume())
end

function LoveGme:getVolume(v)
  return self.source:getVolume()
end

function LoveGme:voice_error_check(voice)
  if voice < 0 or voice > self.voice_count-1 then
    error("attempt to use voice " .. voice ..
      "\nthere are only voices 0 to " .. self.voice_count-1)
  end
end

return setmetatable({}, {__call = function(_,...) return new(...) end})