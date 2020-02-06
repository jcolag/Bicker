import React from "react";
import PropTypes from "prop-types";
import PuncButton from "./PuncButton";
import ClauseSpan from "./ClauseSpan";

class Paragraph extends React.Component {
  constructor (props) {
    super(props);
  }
  
  choose (text, idx, pid, pnumber, offset) {
    const punct = [
      '.',
      ',',
      '!',
      '?',
      ';',
      ':',
      '(',
      ')',
      '&',
      '/',
      '&ndash;',
      '&#8212;',
      '&mdash;',
      '&#8211;',
      '&hellip;',
      '&#8230;',
    ];

    if (punct.indexOf(text) >= 0) {
      return(<PuncButton
        count={idx}
        key={idx}
        offset={offset}
        pid={pid}
        pnumber={pnumber}
        punc={text}
      />);
    } else {
      return(<ClauseSpan
        clause={text}
        count={idx}
        key={idx}
        offset={offset}
        pid={pid}
      />);
    }
  }
  
  paragraphParts (self, contentArray, pid, pnumber) {
    const components = [];
    const lengths = {
      '.': 1,
      ',': 1,
      '!': 1,
      '?': 1,
      ';': 1,
      ':': 1,
      '(': 1,
      ')': 1,
      '&': 1,
      '/': 1,
      '&ndash;': 2,
      '&#8212;': 2,
      '&mdash;': 3,
      '&#8211;': 3,
      '&hellip;': 3,
      '&#8230;': 3,
    };
    let length = 0;

    contentArray.map(function (c, idx) {
      const corrlen = Object.prototype.hasOwnProperty.call(lengths, c) ?
        lengths[c] : c.length;
      components.push(self.choose(c, idx, pid, pnumber, length));
      length += corrlen;
    });
    return components;
  }
  
  render () {
    const array = JSON.parse(this.props.content.__html);
    const para = this.paragraphParts(
      this,
      array,
      this.props.pid,
      this.props.pnum
    );
    return (
      <React.Fragment>
        <div className="msg-paragraph">
          <p
            className="msg-par-text"
          >
            { para }
          </p>
          <p className="msg-par-avatar">
            <a href='/'>
              <img draggable="false" src={ this.props.avatar } />
            </a>
            <br />
            <span className="id-time">{ this.props.who }</span>
            <br />
            <span
              className="id-time"
              title={ this.props.ts }
            >
              { this.props.when } ago
            </span>
          </p>
        </div>
      </React.Fragment>
    );
  }
}

Paragraph.propTypes = {
  avatar: PropTypes.string,
  pid: PropTypes.number,
  pnum: PropTypes.number,
  text: PropTypes.string,
  ts: PropTypes.string,
  when: PropTypes.string,
  who: PropTypes.string,
};
export default Paragraph
